import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Http "Http";

actor Counter {
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
