# -*- coding: utf-8 -*-

def binpack(articles,bin_cap):   

	#This is a heuristic to solve the binpacking problem; it found the optimal answer every time in testing while operating many times faster.

    bin_contents = []    # use this list document the article ids for the contents of 
                         # each bin, the contents of each is to be listed in a sub-list
    
    #I use the below to control loop flow. If you wrap nested loops in this, you can break into an outer loop without
    #continuing on in the lower one. You can use break for this as well, but this is a more comprehensive loop. 
    class Continueloop(Exception):
        pass
    
    continue_i = Continueloop()
    
    maxBins = len(articles)
    initialList = []
    #make an initial list that's as big as we could possibly need
    for i in range(maxBins):
        initialList.append([])
    i = 0
    
    sortedArticles = sorted(articles, key=articles.get, reverse=True) #sort the items by their size
    #print sortedArticles
    load = 0
    for item in sortedArticles:
        try:
            for i in initialList:
                load = sum(list(map(lambda x: articles[x],i))) #uses list and map to find out the value of the current bin
                if articles[item] + load <= bin_cap: #if the article's weight and the bin's load are less than the bin cap
                    initialList[initialList.index(i)].append(item) #Put it in
                    raise continue_i #exit the loop
        except Continueloop:
            continue #puts us on the next item in articles, without doing list copying and such nonsense
    

    #remove all the empty lists (bins) in initialList that weren't needed
    list2 = [x for x in initialList if x != []]
    
    bin_contents = list2

            
    return bin_contents    