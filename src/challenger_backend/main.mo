import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
actor {
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

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

 
};
