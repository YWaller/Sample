require(plyr)
require(RMySQL)
require(pracma)

#This is a simple script demonstrating that R can be used to connect to a database.

con<-dbConnect(RMySQL::MySQL(), dbname = '', username = '', password = '')
dbListTables(con)
dc<-(df<-dbGetQuery(con, 'select * from wm_dcs'))
st<-(df<-dbGetQuery(con, 'select * from wm_stores'))
#head(dc)
#head(st)
ww_mileage<-merge(data.frame(dc=dc), data.frame(st=st),by=NULL);
#head(ww_mileage)
nrow(ww_mileage)-(nrow(dc$dc_id)*nrow(st$store_id)) #Must be zero
for (i in 1:nrow(ww_mileage)){
  ww_mileage$distance[i]<-haversine(c(ww_mileage$dc.lat[i], ww_mileage$dc.lon[i]) , c(ww_mileage$st.lat[i], ww_mileage$st.lon[i]))
}
#head(ww_mileage$distance)
#str(ww_mileage$distance)

addtodb<-as.data.frame(subset(ww_mileage,select=c(dc.dc_id,st.store_id,distance)))
#str(addtodb)

dbWriteTable(con, value = addtodb, name = 'wm_mileage', append=FALSE, overwrite=TRUE, row.names=FALSE) 

















