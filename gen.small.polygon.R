source("dirs.R")
if (!exists(file.path(aux.dir, "mylib"))) source(file.path(aux.dir, "mylib.R"))
mylib(c("data.table", "magrittr", "ggplot2", "geojsonio", "sp","ggvoronoi",
        "tbart", "rgdal", "deldir", "GISTools", "tmap","spatstat", "gstat"))

dt0 <- fread("./dt_rent_path.csv")
dt0 <- dt0[!(rent_lat==0|return_lat==0)]
dt0[rent_lng<0, rent_lng:=abs(rent_lng)]
stopifnot(nrow(dt0[(rent_lat<0|rent_lng<0|return_lat<0|return_lng<0)])==0)
set.seed(5678)
idx <- sample(nrow(dt0), 10000)
dt <- dt0[idx,]
sp1 <- SpatialPoints(dt[, .(rent_lng, rent_lat)], proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
sp2 <- SpatialPoints(dt[, .(return_lng, return_lat)], proj4string=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

n <- geojsonio::geojson_read("../divide_operation_by_district/operation.geojson", method="local", what = "sp")
proj4string(n) <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# sp1.new <- spsample(sp1,n=10000,type="stratified")

# library(raster)
# ggg <-raster(crs = n@proj4string,
#              ext = extent(n@bbox),
#              resolution = 1000)
# library(gstat)
# i = idw(var~1, sp1.new, ggg, nmax = 1, maxdist = 500)
# library(sp)
# spplot(i[1])

source(file.path(aux.dir, "slackme.R"))
for (pp in c(10, 20, 40, 60)) {
    p.result <- allocations(sp1, sp2, p=pp, verbose = T)
    save(p.result, file=sprintf("./data/tbart_%s.RData", pp))
}
slackme("test", st.tm)


tm_shape(n1) + tm_fill(alpha=.3, col = "gray") +
    tm_borders(alpha=.5, col = "black") +
    tm_shape(sp1.new) + tm_dots(col = "blue", scale = 1)
    # tm_shape(sp1[idx,]) + tm_dots(col = "blue", scale = 1)
