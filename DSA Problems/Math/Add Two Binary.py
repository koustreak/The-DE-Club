'''
Given two binary strings a and b, return their sum as a binary string.

 

Example 1:

Input: a = "11", b = "1"
Output: "100"

Example 2:

Input: a = "1010", b = "1011"
Output: "10101"

'''

class Solution:
    def addBinary(self, a, b):
        s = ''
        carry = 0
        i = len(a)-1
        j = len(b)-1

        while i>=0 or j>=0 or carry:
            if i>=0:
                carry+=int(a[i])
                i-=1
            if j>=0:
                carry+=int(b[j])
                j-=1
            s = str(carry%2) + s
            carry //=2
        return s

print(Solution().addBinary('1010','1011'))