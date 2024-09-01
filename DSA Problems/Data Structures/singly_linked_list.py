import warnings

class node:
    def __init__(self,value,next=None):
        self.__data = value 
        self.__next = next
    
    def getdata(self):  return self.__data

    def getnext(self): return self.__next

    def setdata(self,value): self.__data = value

    def setnext(self,node): self.__next = node 

class singly_linked_list:

    def __init__(self,head=None):
        self.__head = head
        self.__size = int(head is not None)
    
    def getsize(self): return self.__size

    def setsize(self,value): self.__size = value

    def gethead(self): return self.__head

    def sethead(self,node): self.__head = node  

    def push_front(self,node):
        if self.gethead() is not None:
            node.setnext(self.gethead())
        self.sethead(node)
        self.setsize(self.getsize()+1)

    def push_rear(self,node):
        if self.gethead() is None:
            raise RuntimeError("No head, List is empty")
        current = self.gethead()
        while current.getnext() is not None:
            current = current.getnext()
        current.setnext(node)
        self.setsize(self.getsize()+1)

    def push_middle(self,node,pos):

        if self.gethead() is None:
            raise RuntimeError("No head, List is empty")
        if pos >= self.getsize() or pos < 0:
            raise ValueError("Position Value is out of bounds")
        if pos == 0:
            self.push_front(node)
        else:
            current = self.gethead()
            count = 0
            while count < pos-1:
                count += 1
                current = current.getnext()
            if current is not None:
                node.setnext(current.getnext()) 
            current.setnext(node)
        self.setsize(self.getsize()+1)

    def delete_front(self):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        self.sethead(self.gethead().getnext())
        self.setsize(self.getsize()-1)

    def delete_rear(self):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        current = self.gethead()
        prev = current
        while current.getnext() is not None:
            prev = current
            current = current.getnext()
        prev.setnext(None)
        self.setsize(self.getsize()-1)

    def delete_middle(self,pos):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        if pos >= self.getsize() or pos < 0:
            raise ValueError("Position Value is out of bounds")
        elif pos == 0:
            self.delete_front()
        elif pos == self.getsize-1:
            self.delete_rear()
        else:
            current = self.gethead()
            count = 0
            while count < pos-1:
                count = count + 1
                current = current.getnext()
            current.setnext(current.getnext().getnext())
        self.setsize(self.getsize()-1)

    def delete_with_value(self, value):
        if self.gethead() is None:
            raise RuntimeError("Head is None, Can not perform delete operation")
        current = self.gethead()
        prev = self.gethead()
        while current is not None:
            if current.getdata() == value:
                break
            prev = current
            current = current.getnext()
        prev.setnext(current.getnext())
        self.setsize(self.getsize()-1)

    def delete_linkedlist(self):
        self.sethead(None)
        
    def reverse(self):
        if self.gethead() is None:
            raise RuntimeError("No head, List is empty")
        current = self.gethead()
        prev = None 
        while current:
            next_node = current.getnext()
            current.setnext(prev)
            prev = current
            current = next_node
        self.sethead(prev)            
        
    def pprint(self):
        if self.gethead() is None:
            raise RuntimeError("No head, List is empty")
        current = self.gethead()
        while current is not None:
            if current.getnext() is not None:
                print(current.getdata(),end=' --> ')
            else:
                print(current.getdata())
            current = current.getnext()

    @staticmethod
    def from_collections(collections):
        if (not collections) and ((not isinstance(collections,list)) or (not isinstance(collections,tuple)) or (not isinstance(collections,set))):
            raise ValueError("can not create linked list from the input as it is None , or  \
                it is not a list or tuple or set ")
        else:
            linkedlist = singly_linked_list()
            for i in collections:
                node_obj = node(value=i,next=None)
                if linkedlist.gethead() is None:
                    linkedlist.sethead(node_obj)
                else:
                    linkedlist.push_rear(node_obj)
            return linkedlist



llist = singly_linked_list.from_collections([2,22,5,99,75,6])
print(llist.getsize())
llist.pprint()
llist.reverse()
llist.pprint()
llist.push_front(node(101))
llist.push_rear(node(102))
llist.pprint()
print(llist.getsize())
llist.push_middle(node(103),4)
llist.pprint()
llist.push_middle(node(106),0)
llist.pprint()