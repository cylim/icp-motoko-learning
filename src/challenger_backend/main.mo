import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Http "Http";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

actor Counter {
  //
  // Lesson 4
  //
  public type Message = {
    text: Text;
    time: Time.Time;
  };
  public type Microblog = actor {
    follow : shared (Principal) -> async ();
    follows : shared query () -> async [Principal];
    post : shared (Text) -> async ();
    posts : shared query (Time.Time) -> async [Message];
    timeline : shared (Time.Time) -> async [Message];
  };
  let filterTime = func (since: Time.Time) : Message -> Bool { func(m: Message): Bool { m.time >= since } };

  stable var followed : List.List<Principal> = List.nil();
  stable var messages : List.List<Message> = List.nil();

  public shared func follow(id : Principal) : async () {
    followed := List.push(id, followed);
  };

  public shared query func follows() : async [Principal] {
    List.toArray(followed);
  };

  public shared (msg) func post(text : Text) : async () {
    // D.print("sender: " # Principal.toText(msg.caller));
    let message: Message = { text = text; time = Time.now() };
    messages := List.push(message, messages);
  };

  public shared query func posts(since: Time.Time) : async [Message] {
    let filteredMessages = List.filter(messages, filterTime(since));
    List.toArray(filteredMessages);
  };

  public shared func timeline(since: Time.Time) : async [Message] {
    var all : List.List<Message> = List.nil();

    for (id in Iter.fromList(followed)) {
      let canister : Microblog = actor (Principal.toText(id));
      let msgs = await canister.posts(since);
      for (msg in Iter.fromArray(msgs)) {
        all := List.push(msg, all);
      };
    };

    List.toArray(all);
  };

  //
  // Lesson 3
  //
  stable var counter = 0;

  public query func get() : async Nat {
    return counter;
  };

  public func set(n : Nat) : async () {
    counter := n;
  };

  public func inc() : async () {
    counter += 1;
  };

  public query func http_request(req: Http.HttpRequest) : async Http.HttpResponse {
    {
      body = Text.encodeUtf8("<h1>" # Nat.toText(counter) # "</h1>");
      headers = [];
      status_code = 200;
    }
  };


  //
  // Lesson 2
  //
  func quicksort(arr : [Int]) : [Int] {
    let length = arr.size();
    if (length <= 1) { return arr };

    let pivot = arr[0];
    let arrPivot : [Int] = Array.subArray<Int>(arr, 1, arr.size() - 1);
    let left : [Int] = Array.filter<Int>(arrPivot, func x = x < pivot);
    let right : [Int] = Array.filter<Int>(arrPivot, func x = x >= pivot);

    let buf = Buffer.fromArray<Int>(quicksort(left));
    buf.add(pivot);
    buf.append(Buffer.fromArray<Int>(quicksort(right)));

    Buffer.toArray(buf);
  };

  public query func qsort(arr : [Int]) : async [Int] {
    quicksort(arr);
  };

  //
  // Lesson 1
  //
  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };
};
