# -*- coding: utf-8 -*-
"""
Created on Tue Dec 5 14:10:45 2017

@author: Yale
"""

#This file is a sample gurobi model that finds optimal connections between locations from a database based on the Haversine distance. 

import MySQLdb as mysql
from gurobipy import *
import re
from operator import itemgetter

db = mysql.connect(user = 'root', passwd = 'redacted', host = 'localhost', db = 'final')
cursor = db.cursor()

store = {}
cursor.execute('select * from store')
for row in cursor.fetchall():
    store[row[0]] = row[1]   
dc = {}
cursor.execute('select * from dc')
for row in cursor.fetchall():
    dc[row[0]] = row[1]    
mileage = {}
cursor.execute('select * from mileage')
for row in cursor.fetchall():
    mileage[(row[0],row[1])] = row[2]

m = Model("prototype")              
m.ModelSense = GRB.MINIMIZE

#add decision variables
supply = []
decision_bi = []     
for i in range(len(dc)):
    row_temp_s = []
    row_temp_d = []
    for j in range(len(store)):
        row_temp_s.append(m.addVar(vtype=GRB.INTEGER, name='dc'+str(i)+'_st'+str(j), lb=0.0))
        row_temp_d.append(m.addVar(vtype=GRB.BINARY, name='dc'+str(i)+'_st'+str(j)+'_1/0', lb=0.0))
    supply.append(row_temp_s)
    decision_bi.append(row_temp_d)
m.update()

#add constraints
store_demand = []
for i in range(len(dc)):
    row_temp = []
    for j in range(len(store)):
        row_temp.append(store[j] * decision_bi[i][j])
    store_demand.append(row_temp)
for i in range(len(dc)):
    m.addConstr(quicksum(supply[i][j] * 1 for j in range(len(store))), GRB.LESS_EQUAL, 12000, 'sup <= cap')
for i in range(len(store)):
    row_temp = []
    for j in range(len(dc)):
        row_temp.append(decision_bi[j][i])
    m.addConstr(quicksum(row_temp[k] * 1 for k in range(len(row_temp))), GRB.EQUAL, 1, '1 dc per store')
for i in range(len(dc)):
    m.addConstr(quicksum(store_demand[i][j] * 1 for j in range(len(dc))), GRB.LESS_EQUAL, quicksum(supply[i][j] * 1 for j in range(len(dc))), 'Regional demand >= regional supply')
m.update()

#add objective function
m.setObjective(quicksum(store[j] * decision_bi[i][j] * (mileage[(i,j)] * decision_bi[i][j] * 0.75 + 200) for i in range(len(dc)) for j in range(len(store)))) 
m.update()

m.optimize()

#Make two lists, one with the variable string names one with the binary 1s and 0s
temp_list=[]
for var in m.getVars():
    temp_list.append(str(var.VarName))
temp_list_two=[]
for var in m.getVars():
    temp_list_two.append(var.x)


#First make the first regex that establishes that we only want the binary decision variables
pattern = re.compile(r".*?_1/0")

#Then get the ones that match being binary
matching=[]
matching=[value for value in temp_list if pattern.match(value)]

#Then get the indices of the ones that match as being 1.0 in the second list of binary 1s&0s and thus used in the model
matchingused=[]
matchingused = [ i for i,v in enumerate(temp_list_two) if v==1.0 ]

#Then use itemgetter to only get the ones from the list that match the above conditions from the list of stores
onlyneeded=[]
onlyneeded=itemgetter(*matchingused)(temp_list)

#Then make a new regex and find all the numbers after dc
dclisting=[]
pattern = re.compile(r"(?<=[dc]{2})[0-9]{1,}")

#Put all the results of the dc search into a list so we now have a list of dcs that were used for each store
i=0
for i in range(len(onlyneeded)):
    dclisting.append(re.search(pattern,str(onlyneeded[i])))
    dclisting[i]=dclisting[i].group(0)
    
#Do the same thing for the stores
stlisting=[]
pattern = re.compile(r"(?<=[st]{2})[0-9]{1,}")
i=0
for i in range(len(onlyneeded)):
    stlisting.append(re.search(pattern,str(onlyneeded[i])))
    stlisting[i]=stlisting[i].group(0)

for i in range(len(stlisting)):
    cursor.execute('insert into results values (%s, %s)',(dclisting[i], stlisting[i]))
db.commit()

cursor.close()