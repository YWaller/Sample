#########################################################Import a bunch of modules


from sklearn import datasets
from sklearn import preprocessing
import numpy as np
from sklearn.cross_validation import train_test_split
import random
from sklearn.metrics import mean_squared_error
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
import datetime


import numpy
import pandas
from keras.models import Sequential
from keras.layers import Dense
from keras.wrappers.scikit_learn import KerasClassifier
from keras.utils import np_utils
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import KFold
from sklearn.preprocessing import LabelEncoder
from sklearn.pipeline import Pipeline
import keras
from keras import backend as K
from keras.models import load_model


seed = 909090
numpy.random.seed(seed)

#get the results from the other models and the dataset
dataframe = pandas.read_csv("rpcsendtime.csv")
dataset = dataframe.values

#y values if doing validation
ydf = pandas.read_csv("rpcytime.csv")
dy = ydf.values


X = dataset
x_MinMax = preprocessing.MinMaxScaler()
x = x_MinMax.fit_transform(X)
x.mean(axis=0)
Y = [x[1] for x in dy]

encoder = LabelEncoder()
encoder.fit(Y)
encoded_Y = encoder.transform(Y)
# convert integers to dummy variables (i.e. one hot encoded)
dummy_y = np_utils.to_categorical(encoded_Y)

#make the datasets
x_train, x_test, y_train, y_test = train_test_split(x,dummy_y, test_size=0.2)

#train the model using the functions and layer sizes previously arrived at (partly recorded below the prediction section)
modelt = Sequential()
modelt.add(keras.layers.Dense(450,activation='tanh', input_shape=(48,)))
modelt.add(keras.layers.Dense(300,activation='relu'))
modelt.add(keras.layers.Dense(6,activation='softmax'))
optimizerr = keras.optimizers.SGD(lr=0.01, momentum=0.0, decay=0.0, nesterov=False)
modelt.compile(optimizer= optimizerr, loss='categorical_crossentropy', metrics=['accuracy'])

modelt.fit(x_train, y_train,epochs = 100, batch_size = 32, verbose=1)


modelt.save('neuralcontactpytime.h5')


#########################################################################this is the prediction section


modelt = load_model('neuralcontactpytime.h5')


dataframe = pandas.read_csv("rpcsendtime.csv")
dataset = dataframe.values
ydf = pandas.read_csv("rpcytime.csv")
dy = ydf.values


X = dataset
x_MinMax = preprocessing.MinMaxScaler()
x = x_MinMax.fit_transform(X)
x.mean(axis=0)
Y = [x[1] for x in dy]

encoder = LabelEncoder()
encoder.fit(Y)
encoded_Y = encoder.transform(Y)
# convert integers to dummy variables (i.e. one hot encoded)
dummy_y = np_utils.to_categorical(encoded_Y)


pred3_train = modelt.predict(x)

modelt.evaluate(x,dummy_y)
predstest=modelt.predict_classes(x)
confusion_matrix(dummy_y.argmax(1),predstest)
accuracy_score(dummy_y.argmax(1),predstest)

a = pred3_train.argmax(1)
numpy.savetxt("neuralpredictedtime.csv", a, delimiter=",")

numpy.savetxt("neuralpredictedrangetime.csv", pred3_train, delimiter=",")


###################################################Here is one training procedure for narrowing down where to look for ideal layer sizes:
start_time = datetime.datetime.now()
#Model
#Use for initial pruning, run through them all, and then after this chop these lists down to the most likely candidates and search
#around there
li = ["elu","relu","sigmoid","tanh"]
train = []
test = []
for activator in li:
    for activator2 in li:
        node_li1 = [5, 15, 30, 45, 150]
        for node in node_li1:
            node_li2 = [5, 15, 30, 45, 150]
            for node2 in node_li2:
                model = Sequential()
                model.add(keras.layers.Dense(node,activation=activator, input_shape=(45,)))
                model.add(keras.layers.Dense(node2,activation=activator2))
                model.add(keras.layers.Dense(5,activation='softmax'))
                optimizerr = keras.optimizers.SGD(lr=0.01, momentum=0.0, decay=0.0, nesterov=False)
                model.compile(optimizer= optimizerr, loss='categorical_crossentropy', metrics=['accuracy'])
                
                print(activator)
                print(activator2)
                print(node)
                print(node2) 
                
                model.fit(x_train, y_train,epochs = 10, batch_size = 32, verbose=1)
            
            
                pred3_train = model.predict(x_train)
                mse_3 = mean_squared_error(pred3_train, y_train)
                #print "Train error = ", mse_3
                train.append((activator,activator2,node,node2,mse_3))
                
                pred3_test = model.predict(x_test)
                mse_3 = mean_squared_error(pred3_test, y_test)
                #print "Test error = ", mse_3
                test.append((activator,activator2,node,node2,mse_3))

stop_time = datetime.datetime.now()
print("Time required for optimization: ", (stop_time - start_time))
print(min(train, key = lambda t: t[4]))
print(min(test, key = lambda t: t[4])) 








