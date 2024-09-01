class node:

    def __init__(self,data,next=None,prev=None):
        self.__data = data 
        self.__next = next 
        self.__prev = prev 

    def setdata(self,data): self.__data = data

    def getdata(self): return self.__data

    def setnext(self,node): self.__next = node

    def getnext(self): return self.__next

    def setprev(self,node): self.__prev = node

    def getprev(self): return self.__prev

class doubly_linked_list:

    def __init__(self,head:node):
        self.__head = head
        self.__length = int(length is not None)

    def setlength(self,length): self.__length = length

    def getlength(self): return self.__length

    def sethead(self,node): self.__head = node

    def gethead(self): return self.__head
    
    def insert_front(self,node):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        node.setnext(self.gethead())
        self.gethead().setprev(node)
        self.sethead(node)
        self.setlength(self.getlength()+1)

    def insert_rear(self,node):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        current = self.gethead()
        while current.getnext() is not None:
            current=current.getnext()
        current.setnext(node)
        node.setprev(current)
        self.setlength(current.getlength()+1)

