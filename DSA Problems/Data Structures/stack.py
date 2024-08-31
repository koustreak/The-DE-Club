
class stack(object):

    def __init__(self,size):
        self.__size = size
        self.__stack = [None]*size
        self.__top = -1 
    
    def setsize(self,size):
        self.__size = size

    def getsize(self):
        return self.__size

    def gettop(self):
        return self.__top

    def settop(self,increase=False):
        if increase:
            self.__top += 1
        else:
            self.__top -= 1

    def push(self,value):
        if self.gettop() == self.getsize()-1:
            raise OverflowError("Stack is full, StackOverflowException")
        self.settop(True)
        self.__stack[self.gettop()] = value
    
    def pop(self):
        if self.gettop() == -1:
            raise IndexError("Stack is empty, retriving data from empty stack")
        element = self.__stack[self.gettop()]
        self.settop()
        return element

    def print_statck(self):
        top = self.gettop()
        if top ==-1:
            raise RuntimeError("Can not print empty stack")        
        print('*********** printing the stack******************')            
        while top != -1:
            print(self.__stack[top])
            top -=1
        print('*************END of print *******************')            

obj = stack(5)
obj.push(10)
obj.push(13)
obj.push(9)
print(obj.getsize()) 
print(obj.gettop()) 
obj.print_statck()   
obj.pop()
obj.print_statck()