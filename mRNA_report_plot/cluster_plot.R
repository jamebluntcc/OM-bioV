# 2016-9-9 
# changed on 2016-11-18 plot mRNA_cluster_plot  
# changed on 2017-3-9 plot mRNA_cluster_plot fix on origin_data dim < 2 and plot out < 9
####----
library(tidyverse)
library(reshape2)
library(ggthemes)

#----
argv <- commandArgs(T)
file_path <- argv[1]
output_path <- argv[2]
#----
my_theme <- theme_calc()+theme(
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  axis.text.x = element_text(angle = 90)
)
theme_set(my_theme)
#output_path <- './'
#file_path <- '/media/zxchen/3dddd6c4-2700-41a5-a677-15b165fa4e64/project/mRNA/2017/OM-mRNA-7-Rice-P20170305/OM-mRNA-7-Rice/mRNA_analysis_results/differential_analysis/cluster/clusters_fixed_P_10'
data <- list()
all_files <- dir(file_path)
files <- all_files[grep('subcluster',all_files)] 
for(i in 1:length(files)){
  data[[i]] <- read.delim(file = paste(file_path,files[i],sep = "/"),header = T,sep = '\t')
}

if(length(files) > 9){
  data <- data[1:9]
}
data_df <- list()
for(i in 1:length(data)){
  data_df[[i]] <- as.data.frame(cbind(rownames(t(data[[i]])),
                          t(data[[i]])),row.names = 1:dim(data[[i]])[2],
                          stringsAsFactors = F)
  if(is.vector(data_df[[i]][,2:dim(data_df[[i]])[2]])){
    data_df[[i]][,2:dim(data_df[[i]])[2]] <- as.numeric(data_df[[i]][,2:dim(data_df[[i]])[2]])
    data_df[[i]]$mean <- mean(data_df[[i]][,2:dim(data_df[[i]])[2]]) %>% round(digits = 3)
    data_df[[i]]$num <- 1:dim(data_df[[i]])[1]
    data_df[[i]]$type <- strsplit(files[i],'\\.')[[1]][1]
  }else{
    data_df[[i]][,2:dim(data_df[[i]])[2]] <- apply(data_df[[i]][,2:dim(data_df[[i]])[2]],2,as.numeric)
    data_df[[i]]$mean <- apply(data_df[[i]][,2:dim(data_df[[i]])[2]],1,mean) %>% round(digits = 3)
    data_df[[i]]$num <- 1:dim(data_df[[i]])[1]
    data_df[[i]]$type <- strsplit(files[i],'\\.')[[1]][1]
  }
  names(data_df[[i]]) <- c('name',colnames(t(data[[i]])),'mean','num','type')
}
all_subcluster_data <- NULL
for(i in 1:length(data_df)){
  tmp <- melt(data_df[[i]],id = c('name','num','type'))
  all_subcluster_data <- rbind(all_subcluster_data,tmp)
}
all_subcluster_data$color <- ifelse(all_subcluster_data$variable == 'mean','blue','grey60')
col <- all_subcluster_data$color;names(col) <- col
cluster_plot <- ggplot(aes(x=reorder(name,num),y=value,group = variable,colour = color),data = all_subcluster_data)+
  geom_line()+geom_point()+expand_limits(y = c(0,1))+scale_color_manual(values = col)+
  xlab("")+ylab("")+guides(color = F)+facet_wrap(~type,nrow = 3,scales = 'free_y')

ggsave(filename=paste(output_path, 'cluster_plot.png', sep="/"),type="cairo-png",plot=cluster_plot ,width = 14,height = 15)
# # for line plot
# plot_line <- function(data){
#   melt_df <- melt(data,id = c('name','num'))
#   melt_df$color <- ifelse(melt_df$variable == 'mean','blue','grey60')
#   col <- melt_df$color;names(col) <- col
#   gg <- ggplot(aes(x=reorder(name,num),y=value,group = variable,colour = color),data = melt_df)+
#     geom_line()+geom_point()+expand_limits(y = c(0,1))+
# #    scale_y_continuous(breaks = seq(from = 0,to = 1,by = 0.2),
# #                       labels = seq(from = 0,to = 1,by = 0.2))+
#     scale_color_manual(values = col)+
#     #theme(axis.title = element_text(size = rel(0.5)))+
#     xlab("")+ylab("")+guides(color = F)
# }
# #for heatmap
# # mat_data <- NULL
# # for(i in data){
# #   mat_data <- rbind(mat_data,i)
# # }
# # mat_data$name <- row.names(mat_data)
# # data <- scale(mat_data[,-dim(mat_data)[2]])
# # ord <- hclust(dist(data))$order
# # pd <- as.data.frame(data)
# # pd$name <- rownames(mat_data)
# # pd.m <- melt(pd,id = 'name')
# # pd.m$name <- factor(pd.m$name,levels = rownames(mat_data)[ord],labels = rownames(mat_data)[ord])
# # pd.m$variable <- factor(pd.m$variable,levels = colnames(mat_data),labels = colnames(mat_data))
# 
# # heatmap <- ggplot(pd.m,aes(variable,name))+geom_tile(aes(fill = value),width = 1,colour = 'grey60')+
# #   scale_fill_gradientn(colors = colorRampPalette(c("#377EB8","white","#E41A1C"))(50))+xlab("")+
# #   ylab("")+guides(fill = F)+
# #   theme(panel.border = element_blank(),
# #         axis.ticks = element_blank())
# #         #axis.title = element_text(size = rel(0.8)))
# if(length(data_df) < 0){
#   stop("there is no cluster!")
# }else{
#   cluster_plot <- grid.arrange(do.call(plot_line,data_df),ncol = 3)
# }
# 
# 
# data_df <- data_df[1:9]
# #pdf(file = paste(output_path,'mRNA_cluster_plot.pdf',sep = '/'),width = 14,height = 15)
# cluster_plot <- grid.arrange(plot_line(data_df[[1]]),plot_line(data_df[[2]]),plot_line(data_df[[3]]),
#              plot_line(data_df[[4]]),plot_line(data_df[[5]]),plot_line(data_df[[6]]),
#              plot_line(data_df[[7]]),plot_line(data_df[[8]]),plot_line(data_df[[9]]),ncol = 3)
# #dev.off()








