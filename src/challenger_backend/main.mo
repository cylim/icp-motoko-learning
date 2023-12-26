import Array "mo:base/Array";
actor {
  func quicksort(arr : [Int]) : [Int] {
    let length = arr.size();
    if (length <= 1) { return arr };

    let pivot = arr[0];
    let arrPivot : [Int] = Array.subArray<Int>(arr, 1, arr.size() - 1);
    let left : [Int] = Array.filter<Int>(arrPivot, func x = x < pivot);
    let right : [Int] = Array.filter<Int>(arrPivot, func x = x >= pivot);

    Array.append<Int>(Array.append<Int>(quicksort(left), [pivot]), quicksort(right));
  };

  public query func qsort(arr : [Int]) : async [Int] {
    quicksort(arr);
  };

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

 
};
