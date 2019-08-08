source("dirs.R")
if (!exists(file.path(aux.dir, "mylib"))) source(file.path(aux.dir, "mylib.R"))
mylib(c("data.table", "magrittr", "ggplot2", "geojsonio", "sp","ggvoronoi",
        "tbart", "rgdal", "deldir", "GISTools", "tmap","spatstat"))

dt <- fread("./illegal_tickets_location/macay_list.csv")
dt <- dt[!(rent_lat==0|return_lat==0)]
dt[rent_lng<0, rent_lng:=abs(rent_lng)]
sp1 <- SpatialPoints(dt[, .(rent_lng, rent_lat)], proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
sp2 <- SpatialPoints(dt[, .(return_lng, return_lat)], proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

result2 <- allocations(sp1, sp2, p=10, verbose = T)
save(result2, file="tbart.RData")
load("tbart.RData")
x <- star.diagram(sp1, sp2, result2$allocation)
# result1 <- allocate(sp1, sp2, p=3, verbose = T)
result <- tbart::tb(sp1, sp2, p=10, verbose = T)


plot(x)
plot(result2,border='grey')
plot(x,col='darkblue',lwd=2,add=TRUE)



n <- geojsonio::geojson_read("../divide_operation_by_district/operation.geojson", method="local", what = "sp")
n1 <- geojsonio::geojson_read("../divide_operation_by_district/operation_by_district.geojson", method="local", what = "sp")
# tm_shape(n1) + tm_fill(alpha=.3, col = "gray") +
#     tm_borders(alpha=.5, col = "black")
proj4string(n) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# n.fort <- tidy(n, region='Operation_district')
# s <- coordinates(result2)[result,] %>% data.frame()
# s <- result2[result2$allocation %>% unique(), "rent_lng","rent_lat"] %>% data.frame()
set.seed(1259)
idx <- sample(nrow(result2), 10)
s <- result2[idx,] %>% data.frame()
setnames(s, c("rent_lng","rent_lat"), c("lat", "long"))
w <- owin(c(n@bbox["x","min"], n@bbox["x","max"]),c(n@bbox["y","min"], n@bbox["y","max"]))
dat.pp <- as(dirichlet(s.ppp <- as.ppp(s, w)), "SpatialPolygons")
dat.pp <- as(dat.pp,"SpatialPolygons")
#proj4string(dat.pp) <- CRS("+init=epsg:4326")
proj4string(result2) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
proj4string(dat.pp) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

int.Z <- over(dat.pp, result2[result2$allocation %>% unique(),], fn=mean)
thiessen <- SpatialPolygonsDataFrame(dat.pp, int.Z)
tm_shape(n) + tm_fill(alpha=.3, col = "gray") +
    tm_shape(thiessen) +  tm_borders(alpha=.5, col = "black") +
    tm_shape(result2[idx,]) + tm_dots(col = "blue", scale = 1)

ggplot(n.fort, aes(x=long, y=lat, group=group)) + geom_polygon(color="black", fill="white")
    # geom_point(data=s, aes(rent_lng, rent_lat))
ggplot(s, aes(rent_lng, rent_lat)) + geom_point() 
ggplot(n.fort, aes(x=long, y=lat))+
        geom_path(aes(group=group),color="black")+
        geom_point(data=s, aes(rent_lng, rent_lat))

ggplot(n.fort, aes(x=long, y=lat))+
    geom_path(aes(group=group),color="black")+geom_voronoi(outline=s)

# writeOGR(n, "./", layer = "n", driver = "ESRI Shapefile")
# spatialPolygon <- readOGR(dsn="../divide_operation_by_district/operation.geojson", verbose = F, p4s = '+init=epsg:4326')
# plot(u, col="#7f7f7f")
# plot(u,border='grey')
# plot(x,col='darkblue',add=TRUE)

plot(n,col=brewer.pal(5,"Accent"))
plot(n1,border=rgb(0,0,0,0.1),add=TRUE)
# plot.new()
points(coordinates(result2)[result,],pch=16,cex=2,col="red")

# allocations.list <- allocate(georgia2,p=5)
# zones <- gUnaryUnion(georgia2,allocations.list)
# plot(zones,col=brewer.pal(5,"Accent"))
# plot(georgia2,border=rgb(0,0,0,0.1),add=TRUE)
# points(coordinates(georgia2)[allocations.list,],pch=16,cex=2,col=rgb(1,0.5,0.5,0.1))





data(meuse)
coordinates(meuse) <- ~x+y
allocations.list <- allocate(meuse,p=5)
star.lines <- star.diagram(meuse,alloc=allocations.list)
plot(star.lines)
# Acquire allocations from swdf1
mylib("GISTools")
set.seed(461976) # Reproducibility
data(georgia)
georgia3 <- allocations(georgia2,p=8)
plot(georgia3,border='grey')
plot(star.diagram(georgia3),col='darkblue',lwd=2,add=TRUE)

require(RColorBrewer)
require(GISTools)
data(georgia)
allocations.list <- allocate(georgia2,p=5)
zones <- gUnaryUnion(georgia2,allocations.list)
plot(zones,col=brewer.pal(5,"Accent"))
plot(georgia2,border=rgb(0,0,0,0.1),add=TRUE)
points(coordinates(georgia2)[allocations.list,],pch=16,cex=2,col=rgb(1,0.5,0.5,0.1))


data(meuse)
coordinates(meuse) <- ~x+y
allocations.list <- allocate(meuse,p=5)
star.lines <- star.diagram(meuse,alloc=allocations.list)
plot(star.lines)

# Acquire allocations from swdf1
require(GISTools)
set.seed(461976) # Reproducibility
data(georgia)
georgia3 <- allocations(georgia2,p=8)
plot(georgia3,border='grey')
plot(star.diagram(georgia3),col='darkblue',lwd=2,add=TRUE)




tm_shape(result2) + tm_polygons()
tm_shape(result2) +
    tm_dots(col="allocdist", palette = "RdBu", stretch.palette = FALSE,
            title="Sampled precipitation \n(in inches)", size=0.7)

th  <-  as(dirichlet(as.ppp()), "SpatialPolygons")





library(rgdal)
library(tmap)

# Load precipitation data
z <- gzcon(url("http://colby.edu/~mgimond/Spatial/Data/precip.rds"))
P <- readRDS(z)

# Load Texas boudary map
z <- gzcon(url("http://colby.edu/~mgimond/Spatial/Data/texas.rds"))
W <- readRDS(z)

# Replace point boundary extent with that of Texas
P@bbox <- W@bbox

tm_shape(W) + tm_polygons() +
    tm_shape(P) +
    tm_dots(col="Precip_in", palette = "RdBu", stretch.palette = FALSE,
            title="Sampled precipitation \n(in inches)", size=0.7) +
    tm_text("Precip_in", just="left", xmod=.5, size = 0.7) +
    tm_legend(legend.outside=TRUE)



library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)    # Used to clip out thiessen polygons

# Create a tessellated surface
th  <-  as(dirichlet(as.ppp(P)), "SpatialPolygons")

# The dirichlet function does not carry over projection information
# requiring that this information be added manually
proj4string(th) <- proj4string(P)

# The tessellated surface does not store attribute information
# from the point data layer. We'll use the over() function (from the sp
# package) to join the point attributes to the tesselated surface via
# a spatial join. The over() function creates a dataframe that will need to
# be added to the `th` object thus creating a SpatialPolygonsDataFrame object
th.z     <- over(th, P, fn=mean)
th.spdf  <-  SpatialPolygonsDataFrame(th, th.z)

# Finally, we'll clip the tessellated  surface to the Texas boundaries
th.clp   <- raster::intersect(W,th.spdf)

# Map the data
tm_shape(th.clp) + 
    tm_polygons(col="Precip_in", palette="RdBu", auto.palette.mapping=FALSE,
                title="Predicted precipitation \n(in inches)") +
    tm_shape(P) +
    tm_text("Precip_in", just="left", xmod=-0.5, size = 0.7) +
    tm_legend(legend.outside=TRUE)



spdf <- geojson_read("https://raw.githubusercontent.com/gregoiredavid/france-geojson/master/communes.geojson",  what = "sp")
spdf = spdf[ substr(spdf@data$code,1,2)  %in% c("06", "83", "13", "30", "34", "11", "66") , ]


# https://cran.r-project.org/web/packages/sp/vignettes/over.pdf
data(meuse.grid)
gridded(meuse.grid) = ~x+y
image(meuse.grid)
points(spsample(meuse.grid,n=1000,type="random"), pch=3, cex=.5)
image(meuse.grid)
points(spsample(meuse.grid,n=1000,type="stratified"), pch=3, cex=.5)
image(meuse.grid)
points(spsample(meuse.grid,n=1000,type="regular"), pch=3, cex=.5)
image(meuse.grid)
points(spsample(meuse.grid,n=1000,type="nonaligned"), pch=3, cex=.5)






