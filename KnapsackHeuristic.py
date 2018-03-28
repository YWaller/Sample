# -*- coding: utf-8 -*-
def load_knapsack(things,knapsack_cap):

    #this program solves the common knapsack problem using a heuristic that in testing found either the optimal or a 3% off optimal solution many times faster
	#than an enumeration solution. 
	
    items_to_pack = []    # use this list for the indices of the items you load into the knapsack
    load = 0.0            # use this variable to keep track of how much volume is already loaded into the backpack
    value = 0.0           # value in knapsack
    #get all item keys here
    item_keys = [k for k in things.keys()]
    
   
    ratio = []
    ordered = []
    for key in item_keys:
        ratio.append((key,(things[key][1]/things[key][0]))) #make a list of all items based on the ratio of value/volume
        ordered.append((key,things[key][1],things[key][0])) #we'll need ordered later
        
    ratio.sort(key=lambda t: t[1],reverse=True) #sort them top to bottom

    ordered.sort(key=lambda t: t[1],reverse=True) #used for final check of items to add

    ratio2 = ratio[:]
    load2 = 0.0
    
    ratio2.sort(key=lambda t: t[1],reverse=False)

    for item in ratio: #this one is fairly simple, if it's got the best ratio and will fit, put it in.
        if (things[item[0]][0] + load <= knapsack_cap):
            items_to_pack.append(item[0])
            ratio.remove(item)
            load += things[item[0]][0]
    
    items_to_pack2 = []        
    for item in ratio2: #uses the reversed items_to_pack
        if (things[item[0]][0] + load2 <= knapsack_cap):
            items_to_pack2.append(item[0])
            ratio2.remove(item)
            load2 += things[item[0]][0]    

    valuan = 0.0
    electric = 0.0
    for item in items_to_pack:
        valuan += things[item][1]
    
    for item in items_to_pack2:
        electric += things[item][1]
        
    if valuan < electric:
        items_to_pack = items_to_pack2
        ratio = ratio2
        load = load2
    
    for item in items_to_pack: #check if anything in the sack has more value and will fit in the sack.
        for leftover in ratio:
            #if the leftover's value is greater than the item's value:
            if (things[item][1] < things[leftover[0]][1]):
                #if load minus the item's weight and plus the leftover's weight isn't over the load limit:
                if (load - things[item][0] + things[leftover[0]][0]) <= knapsack_cap:
                    try:
                        items_to_pack.remove(item)
                        load = load - things[item][0]
                        items_to_pack.append(leftover[0])
                        load = load + things[leftover[0]][0]
                        #print "item swapped"
                    except:
                        pass
     
    allpair = []
    for p1 in range(len(ratio)):
            for p2 in range(p1+1,len(ratio)):
                if [ratio[p2],ratio[p1]] not in allpair:
                    allpair.append([ratio[p1],ratio[p2]]) #generate all possible pairs of items, excluding reversed ones 
                    
    removecount = 0
    itemcount = 0
    paircount = 0
    items_to_pack3 = items_to_pack[:]
    for item in items_to_pack3:
        removecount = 0
        itemcount += 1
        for pair in allpair:
            if pair[0][0] not in items_to_pack: #if the first one isn't in the bag already...
                if pair[1][0] not in items_to_pack:
                    if removecount == 0:
                        if (things[pair[0][0]][0] + things[pair[1][0]][0] - things[item][0] + load) <= knapsack_cap: #if the weight is less than the weight remaining and the thing you're removing
                           if things[pair[0][0]][1] + things[pair[1][0]][1] > things[item][1]: #if the pair has a higher value than the thing...
                               items_to_pack.remove(item)
                               load = load - things[item][0]
                               items_to_pack.append(pair[0][0])
                               items_to_pack.append(pair[1][0])
                               load = load + things[pair[0][0]][0] + things[pair[1][0]][0]
                               removecount = 1
                               paircount += 1

    for item in ordered:
        if item[0] in items_to_pack:
            ordered.remove(item)      
    while min(ordered, key = lambda t: t[2])[2] <= (knapsack_cap - load): #while the lowest weight item is lower than the remaining load...
        for item in ordered:
            if item[0] not in items_to_pack: 
                if things[item[0]][0] + load <= knapsack_cap: #if it will fit...
                    try:
                        items_to_pack.append(item[0])
                        load += things[item[0]][0]
                        ordered.remove(item)
                    except:
                        pass    
                
    remaining = knapsack_cap - load
    #print items_to_pack, "last"
    for item in items_to_pack: #the final set of checks, run every item in there against every remaining item and see if a swap would be good
        for item2 in things:
            if item2 not in items_to_pack:
                if remaining + things[item][0] >= things[item2][0]:
                    if things[item][1] < things[item2][1]:
                        try:
                            items_to_pack.remove(item)
                            items_to_pack.append(item2)
                            load = load - things[item][0]
                            load = load + things[item2][0]
                            remaining = knapsack_cap - load
                        except:
                            pass               
    
    
    return items_to_pack