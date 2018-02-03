# -*- coding: utf-8 -*-
"""
Created on Wed Sep 27 14:05:45 2017

@author: Yale
"""

#This file demonstrates the implementation of several graph search algorithms.

from math import sqrt, log

#linear search
def linearSearch (f, target):
    for x in range(len(f)):
        if (F[x]==target):
            return x
    return False

def linearSearch_sqrt(N):
    epsilon = 0.001 #rate of change
    x = 0.000
    while x*x < N - epsilon: #since we want the square root of N, if our value squared is larger than it, then we've passed the square root. So the value that reaches it but not past it is correct
        x+= epsilon
    return x

print "Linear search:"
print linearSearch_sqrt(15)
print sqrt(15)

#Binary search
def binarySearch(a, target):
    low = 0
    high = len(a) - 1
    idx = False
    
    while low <= high and not idx:
        mid = low + (high - low)/2
        print "LOW {} HIGH {} MID {}, comparing {} to {}".format(low,high,mid,target,a[mid])
        if a[mid] == target:
            return mid
        if a[mid] > target:
            high = mid - 1
        else:
            low = mid + 1 
    return False
    
F = range(32)
target= 4
print "Testing binary search:"
print "looking for [{}] in array {}".format(target, F)
print binarySearch(F,target)

def bisection_search_kth_root(N,k): #standard bisection can be simplified for this case 
    epsilon = 0.001 #rate of change
    bounds = [0, 100000] #set our upper and lower bounds
    while True: #python has no do while loop, so use while True with careful checking that it won't be infinite
        mid = sum(bounds) / 2.0 #get the midpoint
        print "testing value: {}".format(mid)
        delta = mid**k - N #calculate the difference between our guess (mid**k) and N 
        if abs(delta) < epsilon: #if that difference is lower than our error margin...
            break
        bounds[delta > 0] = mid
    return mid

print "Testing bisection search for kth root:"
print bisection_search_kth_root(12,2)

#This bisection search will find the largest number of digits a number can have and still
#fit on a given drive.
def bisection_search_lgN(N):
    low = 0
    spaceondrive = N*(2.0**43.0) #take the input and turn it into bytes
    high = 0.001 #initialize high as a small number to make sure it gets updated
    epsilon = 1 #rate of change is 1 since factorial/bits
    
    while True:
        high = high * 2.0 
        highspace = high * log(high,2.0) - high + 1.0 #get the number of bits the factorial of high would take
        if highspace > spaceondrive: #if that's less than the number of bits on our drive, the high isn't big enough
            break
    
    while True:
        mid = low + (high - low)/2.0 #set the mid
        midspace = mid * log(mid,2.0) - mid + 1.0 #get the number of bits of the mid
        print mid
        if long(midspace) == long(spaceondrive): #use long since if not the above lacks the granularity to reach it/again factorial whole numbers/partial bits issue
            break
        elif midspace > spaceondrive: #if the amount of space is higher, then take away 1
            high = mid - epsilon
        elif midspace < spaceondrive: #being specific so when I look at this later I remember
            low = mid + epsilon #if amount of space our number takes is lower, then add 1
    return mid

print "Testing bisection search for the largest factorial we can fit:"
print bisection_search_lgN(1) #give number of terabytes of hdd


#A simple newton square root for different calculations.
def newton_sqrt(k):
    epsilon = .001
    y= k / 2.0
    while abs(y*y-k) >= epsilon:
        y = y - (((y**2) - k)/(2*y))
    return y

print "Testing the newton_sqrt function:"
print newton_sqrt(12)