##########################################################################################
### In this first script in this series, we illustrate R functionality for retrieving data 
### from Twitter.
### Three techniques are demonstrated:
### 1. Retrieving tweets by keyword
### 2. Retrieving tweets from a specific user
### 3. Retrieving tweets from user lists
###
### The script also illustrates techniques for doing some cleanup tasks using Regular Expressions
##########################################################################################
rm(list=ls())
##########################################################################################
### Functions
##########################################################################################
installIfAbsentAndLoad <- function(neededVector) {
  for(thepackage in neededVector) {
    if( ! require(thepackage, character.only = TRUE) )
    { install.packages(thepackage)}
    require(thepackage, character.only = TRUE)
  }
}
preprocess  <-  function(dataframe) {
  # Using gsub() and regular expressions to clean up tweets.
  # Assumes that the dataframe argument has a variable named
  # text that is the target of this cleanup. This code has
  # been customized to remove unwanted characters that you
  # commonly find in tweets. You can customize what is
  # removed by changing them as you  see fit, to meet your
  # own unique needs.
  dataframe$text  <-  gsub('http\\S+\\s*', ' ', dataframe$text) ## Remove URLs
  dataframe$text  <-  gsub('\\b+RT', ' ', dataframe$text) ## Remove RT
  dataframe$text  <-  gsub('#\\S+', ' ', dataframe$text) ## Remove Hashtags
  dataframe$text  <-  gsub('@\\S+', ' ', dataframe$text) ## Remove Mentions
  dataframe$text  <-  gsub('[[:cntrl:]]', '', dataframe$text) ## Remove Controls and special characters
  # dataframe$text  <-  gsub("\\d", '', dataframe$text) ## Remove numbers
  dataframe$text  <-  gsub("\n", " ", dataframe$text)  ## Remove newline characters
  dataframe$text  <-  gsub('\"', ' ', dataframe$text)   #remove quotation marks
  dataframe$text  <-  gsub("—", " ", dataframe$text)      ##  Remove dashes
  dataframe$text  <-  gsub("&amp;", " ", dataframe$text)    ## Text conversions often cause & to be replaced by &amp - this deletes them
  # dataframe$text  <-  gsub("[[:punct:]]", " ", dataframe$text)  ## Remove punctuation
  # dataframe$text  <-  gsub("[[:digit:]]", " ", dataframe$text)  ## Remove numbers ("\\d" is another way to remove numbers)
  dataframe$text  <-  sapply(dataframe$text, function(row) iconv(row, "latin1", "ASCII", sub=""))  #gets rid of emoji
  dataframe$text  <-  gsub('  ', '', dataframe$text) ## Remove multiple spaces
  dataframe$text  <-  gsub('\t', '', dataframe$text) ## Remove tabs
  return(dataframe)
}
createDirectoryIfAbsent <- function(dir.names, clean=F) {
  # For each element of vector dir.names, creates a 
  # directory of that name as a subdirectory of the working 
  # directory. If the directory is already present, no 
  # action is taken if clean = F (the defaualt), but 
  # otherwise, all existing files are removed from the 
  # existing directory and all subdirectories (but not the
  # directories themselves.
  mainDir <- getwd()
  for(dir.name in dir.names) {
    if (! file.exists(dir.name)){
      dir.create(file.path(mainDir, dir.name))
    }
    if(clean) {
      file.remove(list.files(file.path(mainDir, dir.name), 
                             full.names = T, 
                             all.files = T, 
                             recursive = T))
    }
  }
}
##########################################################################################
### Setup
##########################################################################################
# Load needed packages
needed <- c("rtweet", "httr", "rjson")
installIfAbsentAndLoad(needed)
# Setup to read Twitter data by following the instructions
# provided by the professor. This assumes that you have
# stored your access token in an environment variable.

# Create directories Text and Tweets - if they already exist,
# delete all files in them
createDirectoryIfAbsent(c("Texts", "Tweets"), clean = T)
##########################################################################################
### Example 1: Retrieve tweets by searching Twitter for a 
### keyword. 
##########################################################################################
# Note the parameters...location-specific retrieval is also
# available via geocode specification - free version searches
# only look back 7 days
tweets.goblue  <-  search_tweets('#GoBlue', n = 5000, 
                              lang = 'en',
                              include_rts=F,
                              until=as.character(Sys.Date() - 1))
# Use strip_retweets() to remove retweets, then convert to a data frame
tweets.df.goblue  <-  as.data.frame(tweets.goblue)
# Clean up tweets (see Function definition above)
tweets.goblue.cleaned <- preprocess(tweets.goblue)
# Display first 25 tweets
tweets.goblue.cleaned[1:25, 5]
##########################################################################################
### Example 2: Retrieve tweets from a particular user 
##########################################################################################
tweets.trump  <-  as.data.frame(get_timeline('RealDonaldTrump', n=100))
tweets.trump.cleaned <- preprocess(tweets.trump)
tweets.trump.cleaned[1:25, 5]
##########################################################################################
### Example 3: Retrieve tweets from Twitter Lists 
##########################################################################################
# # To make things easier, here is a function built on top of
# # rtweet::get_timeline():
# #
# Download tweets from a group of people specified in a
# Twitter list.
tweetsFromList  <-  function (listOwner, listName, sleepTime = 5, n_tweets = 200, max_users=1000) {
  accessToken  <-  readRDS(file=Sys.getenv("TWITTER_PAT"))
  api_url  <-  paste0("https://api.twitter.com/1.1/lists/members.json?slug=",
                    listName, "&owner_screen_name=", listOwner, "&count=5000")
  # Pull out the users from the list
  response  <-  GET(api_url, config(token=accessToken))
  mycontent <- content(response, as = "text")   #, as = "text", encoding = "UTF-8")
  response_data  <-  fromJSON(mycontent)
  user_title  <-  sapply(response_data$users, function(i) i$name)
  user_names  <-  sapply(response_data$users, function(i) i$screen_name)

  ## Loops over list of users, use rbind() to add them to list.
  ## Sleeptime ticks inbetween to avoid rate limit.
  num <- 0
  
  for (user in user_names) {
    ## Download user's timeline from Twitter
    num <- num+1
    if(num>max_users) {
      {
        return(tweets)
      }
    }
    else
    {
      raw_data  <-  get_timeline(user, n = n_tweets)
      if(num==1) {
          tweets  <-  as.data.frame(raw_data)
      } else {
        if (length(raw_data) != 0L) {
          # If a Twitter-user has no tweets, userTimeline and rbind fails. The if-else statement solves this.
          tweets  <-  rbind(tweets, as.data.frame(raw_data))
          print('Sleeping to avoid rate limit')
          Sys.sleep(sleepTime);
        } else {
            print(paste('No tweets retrieved for ', user))
            next
        }                
      }
    }
  }
  rm(raw_data)
  return(tweets) 
}
# Let’s get set up to compare tweets from Republican and Democrat House Representatives.
republicans.df  <-  tweetsFromList("HouseGOP", "house-republicans", max_users=25, n_tweets = 10, sleepTime = 1)
republicans.df.cleaned  <-  preprocess(republicans.df)
head(republicans.df.cleaned[5], 25)

democrats.df  <-  tweetsFromList("TheDemocrats", "house-democrats", max_users=25, n_tweets = 10, sleepTime = 1)
democrats.df.cleaned  <-  preprocess(democrats.df)
head(democrats.df.cleaned[5], 25)

# Save cleaned files for later - you will need to create a subdirectory of your working directory called "texts".
# These statements will then write two csv files to that directory. We will use these in the next lab to discuss Text Representation.
write.table(democrats.df.cleaned[5], file=file.path(getwd(), "texts",'democrats.df.cleaned.txt'), sep=",")
write.table(republicans.df.cleaned[5], file=file.path(getwd(), "texts", 'republicans.df.cleaned.txt'), sep=',')
# Break these large collections of tweets into individual tweets in a subdirectory of the working directory called "Tweets
obs <- 0
doc <- 0
for(nextfile in list.files(paste(getwd(), "texts", sep="/"))) {
  doc <- doc+1
  next.df <- read.csv(paste(getwd(), "texts", nextfile, sep="/"), sep=',')
  nobs <- nrow(next.df)
  for(nextobs in 1:nobs) {
    obs <- obs+1
    filename <- gsub(".txt", paste(".Doc", gsub(" ", 0, format(doc, width=4)), "Obs", gsub(" ", 0, format(obs, width=4)), ".txt", sep=""), nextfile)
    write.table(next.df[nextobs, 1], col.names=F, file=paste(getwd(), "Tweets", filename, sep="/"))
  }
}

