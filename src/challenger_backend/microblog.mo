import Text "mo:base/Text";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

actor Microblog {
  public type UserInfo = {
    name : Text;
  };
  public type Author = {
    id : Principal;
    user : UserInfo;
  };
  public type Message = {
    text : Text;
    time : Time.Time;
    author : Author;
  };
  public type InterfaceMicroblog = actor {
    get_name : shared query () -> async ?Text;
    posts : shared (Time.Time) -> async [Message];
    followBy : shared (Principal) -> async Result.Result<Bool, Text>;
  };
  public type Microblog = actor {
    follow : shared (Principal) -> async ();
    follows : shared query () -> async [Principal];
    post : shared (Text) -> async ();
    posts : shared query (Time.Time) -> async [Message];
    timeline : shared (Time.Time) -> async [Message];
  };
  let filterTime = func(since : Time.Time) : Message -> Bool {
    func(m : Message) : Bool { m.time >= since };
  };

  let defaultAuthor : Text = "Anonymous";
  stable var _user : UserInfo = {
    name = "CY";
  };
  stable var _following : List.List<Principal> = List.nil();
  stable var _followedBy : List.List<Principal> = List.nil();
  stable var _messages : List.List<Message> = List.nil();

  private func onlyOwner(caller : Principal) {
    assert (Principal.toText(caller) == "");
  };

  public shared func set_name(_name : Text) { _user := { name = _name } };
  public shared query func get_name() : async ?Text { ?_user.name };

  public shared func follow(id : Principal) : async () {
    _following := List.push(id, _following);
  };

  public shared query func follows() : async [Principal] {
    List.toArray(_following);
  };

  public shared (msg) func post(text : Text) : async () {
    // D.print("sender: " # Principal.toText(msg.caller));
    let message : Message = {
      text = text;
      time = Time.now();
      author = { id = msg.caller; user = _user };
    };
    _messages := List.push(message, _messages);
  };

  public shared query func posts(since : Time.Time) : async [Message] {
    let filteredMessages = List.filter(_messages, filterTime(since));
    List.toArray(filteredMessages);
  };

  public shared func timeline(since : Time.Time) : async [Message] {
    var all : List.List<Message> = List.nil();

    for (id in Iter.fromList(_following)) {
      let canister : Microblog = actor (Principal.toText(id));
      let msgs = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)) {
        all := List.push(msg, all);
      };
    };

    List.toArray(all);
  };

  public shared func getRemoteName(pid : Principal) : async Text {
    try {
      let canister : InterfaceMicroblog = actor (Principal.toText(pid));
      let pokName : ?Text = await canister.get_name();
      let name : Text = switch pokName {
        case null defaultAuthor;
        case (?txt) txt;
      };
    } catch (err) {
      defaultAuthor;
    };
  };
  public shared func authorMatch(pids : List.List<Principal>) : async [Author] {
    var _res : List.List<Author> = List.nil();
    for (pid in Iter.fromList(pids)) {
      _res := List.push<Author>(
        {
          id = pid;
          user = {
            name = await getRemoteName(pid);
          };
        },
        _res,
      );
    };
    List.toArray(_res);
  };
  public shared func getRemotePosts(pid : Principal, since : Time.Time) : async [Message] {
    try {
      let canister : InterfaceMicroblog = actor (Principal.toText(pid));
      await canister.posts(since);
    } catch (err) {
      return [];
    };
  };
};
