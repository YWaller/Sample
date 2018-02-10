# -*- coding: utf-8 -*-
"""
Created on Mon August 28 23:07:21 2017

@author: Yale
"""

#This file serves to demonstrate my understanding of the algorithms and methods that underpin neural nets.
#As I taught myself how to understand and use neural nets, I wanted to be sure I could properly implement one without 
#relying upon black boxes such as scikit-learn. 
#Hence, here is a neural net from scratch that can be used to classify the famous MNIST dataset on digit recognition with
#99.7% accuracy. 


import numpy as nm # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import matplotlib.pyplot as plt
from scipy import optimize as opti

#Define various functions

## This is the sigmoid activation function
def sigmoid(z):
    return 1./(1+ nm.exp(-z));

## This is the gradient of the sigmoid function. Used in backpropogation
def sigmoidGradient(z):
     return sigmoid(z)*(1-sigmoid(z));

    
## This is the cost function, that returns the cost and the gradient of the cost
## as a function of the parameters nn_theta of the neural net. This function is hardcoded
## for two hidden layers

def  nnCostFunc(nnParams, ninputLayerSize, hiddenLSizeOne,hiddenLSizeTwo, numLabels, x, y, lam):

    ## defining the number of parameters  in each layer
    nElemTheta1=hiddenLSizeOne*(1+ninputLayerSize)
    nElemTheta2=(hiddenLSizeOne+1) *hiddenLSizeTwo
    #nElemTheta3=(hiddenLSizeTwo+1)*numLabels


    Theta1=nnParams[0:nElemTheta1].reshape((hiddenLSizeOne, ninputLayerSize+1))
    Theta2=nnParams[nElemTheta1:nElemTheta1+nElemTheta2].reshape((hiddenLSizeTwo, hiddenLSizeOne+1))
    Theta3=nnParams[nElemTheta1+nElemTheta2:].reshape((numLabels, hiddenLSizeTwo+1))


    m= x.shape[0]
       
    j = 0;
    Theta1_grad = nm.zeros(Theta1.shape);
    Theta2_grad = nm.zeros(Theta2.shape);
    Theta3_grad = nm.zeros(Theta3.shape);

    yy=nm.zeros((m, numLabels));
    for i in range(1, numLabels):
        yy[nm.where(y==i)[0], i-1]=1
        
    yy[nm.where(y==0), -1]=1


    a1=nm.append(nm.ones((m,1)), x, axis=1)
    z2=nm.dot(Theta1,a1.T)
    a2=sigmoid(z2).T;
    a2=nm.append(nm.ones((m,1)), a2, axis=1);
    z3=nm.dot(Theta2, a2.T)
    a3=sigmoid(z3).T;
    a3=nm.append(nm.ones((m,1)), a3, axis=1);
    z4=sigmoid(nm.dot(Theta3, a3.T));

   
    #j=nm.sum( -yy   *  nm.log(z3.T)    - (1-yy)* nm.log(1-z3.T)) /m
    j=nm.sum(   nm.log( (z4.T)**(-yy) * (1-z4.T)**(-(1-yy))    ))/m
    #print  j, sum(yy), 1-nm.max(z3), nm.min(z3)
    ## adding regul
    j+=lam/(2.*m)    *(nm.sum(Theta1[:,1:]**2) + nm.sum(Theta2[:,1:]**2)+nm.sum(Theta3[:,1:]**2) )


    #### using backprop to compute the gradient.

    Delta_1ij=nm.zeros(Theta1.shape);
    Delta_2ij=nm.zeros(Theta2.shape);
    Delta_3ij=nm.zeros(Theta3.shape);


    delta4 = z4.T-yy;


#    delta3 = z3.T-yy;
    
    ##3compute delta2
    delta3=(nm.dot(delta4, Theta3)[:, 1:] * sigmoidGradient(z3).T)
    delta2=(nm.dot(delta3, Theta2)[:, 1:] * sigmoidGradient(z2).T)
    ##4 accumulate
    
    
    
    Delta_1ij=nm.dot(delta2.T,a1)/m;
    Delta_2ij=nm.dot(delta3.T, a2)/m;
    Delta_3ij=nm.dot(delta4.T, a3)/m;

    Theta1_grad+=Delta_1ij;
    Theta2_grad+=Delta_2ij;
    Theta3_grad+=Delta_3ij;
    
    Theta1_grad[:,1:]+=lam/m * Theta1[:,1:];
    Theta2_grad[:,1:]+=lam/m * Theta2[:,1:];
    Theta3_grad[:,1:]+=lam/m * Theta3[:,1:];
    
    
    grad=nm.append(nm.append(Theta1_grad.flatten(), Theta2_grad.flatten()), Theta3_grad.flatten())

    return j, grad

def predict2(Theta1, Theta2, Theta3,x):
    global numLabels

    m = x.shape[0];
    numLabels = Theta3.shape[0];
    p = nm.zeros((x.shape[0], 1));
    x=nm.append(nm.ones((m,1)), x, axis=1)
    h1 = sigmoid(nm.dot(x , Theta1.T));
    h1= nm.append(nm.ones((m,1)), h1, axis=1)
    h2 = sigmoid(nm.dot(h1 , Theta2.T));
    h2=nm.append(nm.ones((m,1)), h2, axis=1)
    h3= sigmoid(nm.dot(h2 , Theta3.T));
    p=nm.argmax(h3, axis=1)+1
    p[p==10]=0
    return p

def train2(x, y, hiddenLSizeOne,hiddenLSizeTwo, lam):
    global numLabels
    ninputLayerSize =x.shape[1]
    numLabels=10

    m=x.shape[0]
    print('there are {} training samples here'.format(m))


    eps=0.12
    ## initialing params.
    initial_Theta1 =   nm.random.rand(hiddenLSizeOne, 1+ninputLayerSize) *2*eps -eps   
    initial_Theta2 =   nm.random.rand(hiddenLSizeTwo,   1+ hiddenLSizeOne) *2*eps -eps 
    initial_Theta3 =   nm.random.rand(numLabels,   1+ hiddenLSizeTwo) *2*eps -eps 


    initial_nnParams=nm.append(nm.append(initial_Theta1.flatten(), initial_Theta2.flatten()), initial_Theta3.flatten() )
    
    ## let's compute the cost function and its gradient with the initial_Theta's
    
    #nnCostFunction(initial_nnParams, ninputLayerSize, hidden_layer_size, numLabels, x, y, lam)
     nnCostFunc(initial_nnParams, ninputLayerSize, hiddenLSizeOne,hiddenLSizeTwo, numLabels, x, y, lam)

    
    #res2=opti.minimize(nnCostFunction, initial_nnParams, jac=True, args=(ninputLayerSize, hidden_layer_size, numLabels, x, y, lam), method="L-BFGS-B", tol=1e-6,  options={'disp':True, 'maxiter':300, 'gtol':1e-6})
    res2=opti.minimize( nnCostFunc, initial_nnParams, jac=True, args=(ninputLayerSize, hiddenLSizeOne,hiddenLSizeTwo, numLabels, x, y, lam), method="L-BFGS-B", tol=1e-6,  options={'disp':False, 'maxiter':500, 'gtol':1e-6})
    
    nElemTheta1=hiddenLSizeOne*(1+ninputLayerSize)
    nElemTheta2=(hiddenLSizeOne+1) * hiddenLSizeTwo
    nElemTheta3=(hiddenLSizeTwo+1) * numLabels


    Theta1=(res2.x)[0:nElemTheta1].reshape((hiddenLSizeOne, ninputLayerSize+1))
    Theta2=(res2.x)[nElemTheta1:nElemTheta1+nElemTheta2].reshape((hiddenLSizeTwo, hiddenLSizeOne+1))
    Theta3=(res2.x)[nElemTheta1+nElemTheta2:].reshape(( numLabels, hiddenLSizeTwo+1))

    return Theta1, Theta2, Theta3
## Main script
# Loading the dataset
A=pd.read_csv('train.csv').values
B=pd.read_csv('test.csv').values

## defining the target and the feature matrix.
x=(A[:, 1:]-128)/128.
B=(B[:,:]-128)/128.
y=nm.int32(A[:,0])

N=42000
x_train=x[:N,:]
y_train=y[:N]

x_val=x[N:,:]
y_val=y[N:]

## Plot one digit for illustration
id=244
plt.figure(1)
plt.clf()
plt.imshow(x[id, :].reshape(28, 28), cmap="Greys")
plt.title('True value = {}'.format(y[id]))

lam=0.2

#Launches training, but home-made implementation is slow. 
#T1, T2, T3= train2(x_train, y_train, 15,7, lam)