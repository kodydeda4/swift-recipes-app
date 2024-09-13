import Foundation

extension Array {
  
  /**
   Sorts and groups elements alphabetically by the specified first and last name key paths.
   
   This method sorts the elements of the array first by the specified first name key path. If two elements have the same first name, they are then sorted by the specified last name key path. After sorting, the elements are grouped into a dictionary where the keys are the first letters of the first names.
   
   - Parameters:
   - firstName: A key path to the first name property of the elements.
   - lastName: A key path to the last name property of the elements.
   
   - Returns: A dictionary where the keys are the first letters of the first names, and the values are arrays of elements that have first names starting with the corresponding letter.
   **/
  public func sortAndGroupAlphabetically(
    _ firstName: KeyPath<Element, String>,
    _ lastName: KeyPath<Element, String>
  ) -> [String: Self] {
    self.sorted {
      if $0[keyPath: firstName] == $1[keyPath: firstName] {
        return $0[keyPath: lastName] < $1[keyPath: lastName]
      } else {
        return $0[keyPath: firstName] < $1[keyPath: firstName]
      }
    }
    .reduce(into: [String: Self]()) { result, person in
      let firstLetter = String(person[keyPath: firstName].prefix(1))
      result[firstLetter, default: []].append(person)
    }
  }
}
