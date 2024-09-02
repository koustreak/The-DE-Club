def merge_sorted_arrays_inplace(arr1, arr2):
    # Step 1: Extend arr1 to hold the elements of arr2
    m, n = len(arr1), len(arr2)
    arr1.extend([0] * n)  # Extend arr1 with zeroes or placeholders

    # Step 2: Use two pointers to merge the arrays in place
    i, j, k = m - 1, n - 1, m + n - 1

    # Traverse from the end of arr1 and arr2 and fill arr1 from the back
    while i >= 0 and j >= 0:
        if arr1[i] > arr2[j]:
            arr1[k] = arr1[i]
            i -= 1
        else:
            arr1[k] = arr2[j]
            j -= 1
        k -= 1

    # If there are remaining elements in arr2, copy them
    while j >= 0:
        arr1[k] = arr2[j]
        j -= 1
        k -= 1

# Example usage:
arr1 = [1, 2, 3,7]
arr2 = [0, 5, 6]

merge_sorted_arrays_inplace(arr1, arr2)
print(arr1)
