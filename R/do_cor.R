do_cor <-
function(data_m_fc_withfeats,subindex=NA,targetindex=NA,outloc,networkscope,cor.method,abs.cor.thresh,cor.fdrthresh,
	max.cor.num,net_node_colors,net_legend,netrandseed=555,num_nodes=6, plots.width=2000,plots.height=2000,plots.res=300){
	Sys.sleep(0.2)
dir.create(outloc)
setwd(outloc)
allsig_pcornetwork<-{}
cormat<-{}

		


allsig_pcornetwork_fdr0.05<-{}

#data_m_fc_withfeats<-apply(data_m_fc_withfeats,1,function(x){naind<-which(is.na(x)==TRUE);if(length(naind)>0){ x[naind]<-median(x,na.rm=TRUE)};return(x)})
#		data_m<-t(data_m_fc_withfeats)

allsig_pcornetwork_fdr0.05<-{}

if(dim(data_m_fc_withfeats)[1]>1)
{
	if(is.na(subindex[1])==FALSE){
		goodfeats<-data_m_fc_withfeats[subindex,]
		
	}else{
		goodfeats<-data_m_fc_withfeats
		
		}

if(is.na(targetindex[1])==FALSE){
	data_m_fc_withfeats<-data_m_fc_withfeats[targetindex,]
		
	}else{
		data_m_fc_withfeats<-data_m_fc_withfeats
		
		}
	
	if(is.na(subindex[1])==FALSE){
        if(length(subindex)==nrow(data_m_fc_withfeats)){
            
            data_m_fc_withfeats<-data_m_fc_withfeats
            
        }else{
                data_m_fc_withfeats<-data_m_fc_withfeats[-subindex,]
        }
    }
m1<-apply(data_m_fc_withfeats[,-c(1:2)],2,as.numeric)

print(dim(m1))
rnames<-paste("mzid_",seq(1,dim(data_m_fc_withfeats)[1]),sep="")


rownames(m1)=rnames

data_mt<-t(m1)
}else{
m1<-as.numeric(data_m_fc_withfeats[,-c(1:2)])
#print(dim(m1))
#rownames(m1)=rnames
data_mt<-(m1)

data_mt<-as.matrix(data_mt)

}

#listf<-list.files(".","*.txt",recursive=TRUE)
#for(l1 in listf){pmattemp<-read.table(l1,sep="\t",header=TRUE); cormat<-cbind(cormat,pmattemp[,3])}
goodfeats_inf<-as.data.frame(goodfeats[,c(1:2)])

#print(dim(goodfeats))
#print(dim(data_mt))

#for(l1 in listf){pmattemp<-read.table(l1,sep="\t",header=TRUE); cormat<-cbind(cormat,pmattemp[,3])}
goodfeats<-as.data.frame(goodfeats)

complete_pearsonpvalue_mat<-{}
complete_pearsonqvalue_mat<-{}
	l1<-list.files(".")
	

 print(paste("Computing ",cor.method," matrix",sep=""))
        #system.time(pearson_res<-parRapply(cl,goodfeats[,-c(1:2)],getCorchild,data_mt,cor.method))

		temp_mat<-rbind(goodfeats[,-c(1:2)],t(data_mt))
		
		pearson_res<-WGCNA::cor(t(temp_mat),nThreads=num_nodes,method=cor.method)


		
		pearson_res<-pearson_res[c(1:dim(goodfeats[,-c(1:2)])[1]),-c(1:dim(goodfeats[,-c(1:2)])[1])]
		
		num_samp<-dim(data_mt)[1]


num_samp<-dim(goodfeats[,-c(1:2)])[2]

		 pearson_resmat<-{}
		 
		# print("done")
		 
		 pearson_resvec<-as.vector(pearson_res)
		 
		 pearson_pvalue<-lapply(1:length(pearson_resvec),function(x){
		 	
		 	return(WGCNA::corPvalueStudent(pearson_resvec[x],num_samp))

		 	
		 })
		 
		 complete_pearsonpvalue_mat<-unlist(pearson_pvalue)
		 dim(complete_pearsonpvalue_mat)<-dim(pearson_res)
		 
			cormat<-pearson_res
			
					pearson_Res_all<-{}

		   
		   #print("here 3")
		  # print(head(cormat))
		   #print(dim(cormat[[1]]))
       
        #cormat<-t(cormat)
        cormat<-as.data.frame(cormat)
        cormat<-as.matrix(cormat)

		#print(dim(cormat))
               
               pearson_Res_all<-{}
        
        #complete_pearsonpvalue_mat<-t(complete_pearsonpvalue_mat)
        complete_pearsonpvalue_mat<-as.data.frame(complete_pearsonpvalue_mat)
        complete_pearsonpvalue_mat<-as.matrix(complete_pearsonpvalue_mat)
			
			
			complete_pearsonpvalue_mat<-t(complete_pearsonpvalue_mat)
			cormat<-t(cormat)
			
            #		print(dim(cormat))
            #print(dim(complete_pearsonpvalue_mat))
			

			
			pearson_Res_all<-{}
	#complete_pearsonqvalue_mat<-sapply(1:length(pearson_res),function(j){pearson_Res_all<-rbind(pearson_Res_all,as.matrix(pearson_res[[j]]$complete_pearsonqvalue_mat))})
	

	
	complete_pearsonqvalue_mat<-apply(cormat,2,function(x){
		
		#p.adjust(x,method="BH")
					#print(length(x))
					
					x<-as.numeric(x)
					pdf("fdrtoolB.pdf")
					
					fdr_adjust_pvalue<-try(fdrtool(x,statistic="correlation",verbose=FALSE),silent=TRUE)
					
					if(is(fdr_adjust_pvalue,"try-error")){
					fdr_adjust_pvalue<-NA
					}else{
					fdr_adjust_pvalue<-fdr_adjust_pvalue$qval
					}
					try(dev.off(),silent=TRUE)
					return(fdr_adjust_pvalue)
                    }
		
		)
		
		
        complete_pearsonqvalue_mat<-as.data.frame(complete_pearsonqvalue_mat)
        complete_pearsonqvalue_mat<-as.matrix(complete_pearsonqvalue_mat)
        
setwd(outloc)

	
goodfeats<-as.data.frame(goodfeats)

	colnames(cormat)<-as.character(goodfeats$mz)
	

	data_m_fc_withfeats<-as.data.frame(data_m_fc_withfeats)
	

	rownames(cormat)<-as.character(data_m_fc_withfeats$mz)
	
	cormat<-round(cormat,2)


fname<-paste("correlation_matrix.txt",sep="")
write.table(cormat,file=fname,sep="\t",row.names=TRUE)

fname<-paste("correlation_pvalues.txt",sep="")

complete_pearsonpvalue_mat<-round(complete_pearsonpvalue_mat,2)

   write.table(complete_pearsonpvalue_mat,file=fname,sep="\t",row.names=TRUE)

fname<-paste("correlation_qvalues.txt",sep="")

complete_pearsonqvalue_mat<-round(complete_pearsonqvalue_mat,2)

   write.table(complete_pearsonqvalue_mat,file=fname,sep="\t",row.names=TRUE)




	#nonsig_vs_fdr0.05_pearson_mat<-
	nonsig_vs_fdr0.05_pearson_mat_bool<-cormat

	nonsig_vs_fdr0.05_pearson_mat_bool[complete_pearsonqvalue_mat>cor.fdrthresh]<-0

cormat_abs<-abs(cormat)

 nonsig_vs_fdr0.05_pearson_mat_bool[cormat_abs<abs.cor.thresh]<-0

		rm(cormat_abs)
	
	sum_mat<-apply(nonsig_vs_fdr0.05_pearson_mat_bool,1,sum)

	bad_index<-which(sum_mat==0)
	
	
	
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool
	
	mz_index<-which(data_m_fc_withfeats$mz%in%goodfeats$mz)
	
		if(length(bad_index)>0){
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool[-bad_index,]
	}
	
	
	if(length(mz_index)==length(data_m_fc_withfeats$mz))
	{
		nonsig_vs_fdr0.05_pearson_mat_bool_filt[lower.tri(nonsig_vs_fdr0.05_pearson_mat_bool_filt)==TRUE]<-0
		diag(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-0
	}else{
	
				mz_index<-which(data_m_fc_withfeats$mz%in%goodfeats$mz)
	
	if(length(mz_index)>0){
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[-mz_index,]
	}
		
	}
	
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-unique(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	
	#print(length(nonsig_vs_fdr0.05_pearson_mat_bool_filt))
	#print(dim(nonsig_vs_fdr0.05_pearson_mat_bool))
	
	
	#>=dim(goodfeats)[1]
	if(length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>0){
		
		
		nonsig_vs_fdr0.05_pearson_mat_bool_filt_1<-as.data.frame(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
		
	if(length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>dim(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1)[1] && (length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>1))
	#if((length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>1))
{
	
	

	check_cor<-apply(abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt),1,function(x){max(x,na.rm=TRUE)})
	
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[order(check_cor,decreasing=TRUE),]
		
	#print(head(nonsig_vs_fdr0.05_pearson_mat_bool_filt))
	
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-na.omit(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	fname<-paste("significant_correlations_",networkscope,"_matrix_mzlabels.txt",sep="")
	
    #nonsig_vs_fdr0.05_pearson_mat_bool_filt<-round(nonsig_vs_fdr0.05_pearson_mat_bool_filt,2)
    
	write.table(nonsig_vs_fdr0.05_pearson_mat_bool_filt,file=fname,sep="\t",row.names=TRUE)
	

	fname<-paste("significant_correlations_",networkscope,"CIRCOSformat_mzlabels.txt",sep="")
	
	
	mz_rnames<-rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	mz_cnames<-colnames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	#rnames<-c("Data",rnames)
	
	circos_format<-abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
    #circos_format<-round(circos_format,2)
    
	#circos_format<-rbind(cnames,circos_format)
	circos_format<-cbind(mz_rnames,circos_format)
	
    #
    
	write.table(circos_format,file=fname,sep="\t",row.names=FALSE)
	
	
	rnames<-mz_rnames
	cnames<-mz_cnames
	
	cnames<-seq(1,length(cnames))
	rnames<-seq(1,length(rnames))
	
    id_mapping_mat<-cbind(rnames,mz_rnames)
    
    # id_mapping_mat<-rbind(id_mapping_mat,cbind(cnames,mz_cnames))
    #colnames(id_mapping_mat)<-c("ID","Name")
    #write.csv(id_mapping_mat,file="node_id_mapping.csv",row.names=FALSE)
    
    
	#nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[-which(duplicated(rnames)==TRUE),]
	#rnames<-rnames[-which(duplicated(rnames)==TRUE)]
	
	
	
	#rnames<-rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	#cnames<-colnames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	#cnames<-round(as.numeric(cnames),5)
	#rnames<-round(as.numeric(rnames),5)
    #save(nonsig_vs_fdr0.05_pearson_mat_bool_filt,file="nonsig_vs_fdr0.05_pearson_mat_bool_filt.Rda")
    
    
    if(length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>0)
    {
        
        if(nrow(nonsig_vs_fdr0.05_pearson_mat_bool_filt)>0){
    
    
	colnames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-paste("Y",cnames,sep="")
	rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-paste("X",rnames,sep="")

	fname<-paste("significant_correlations_",networkscope,"_matrix_rowcolnumlabels.txt",sep="")
	
    #nonsig_vs_fdr0.05_pearson_mat_bool_filt<-round(nonsig_vs_fdr0.05_pearson_mat_bool_filt,2)
    
	write.table(nonsig_vs_fdr0.05_pearson_mat_bool_filt,file=fname,sep="\t",row.names=TRUE)
        }else{
            stop("No correlations found.")
        }
    }else{
        
        stop("No correlations found.")
    }
	circos_format<-abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	

	circos_format<-cbind(rnames,circos_format)
 
	fname<-paste("significant_correlations_",networkscope,"CIRCOSformat_rowcolnumlabels.txt",sep="")
	
  
    write.table(circos_format,file=fname,sep="\t",row.names=FALSE)


	if(length(which(check_cor>=abs.cor.thresh))>0){
		
		
	if(is.na(max.cor.num)==FALSE){
	
	if(max.cor.num>dim(nonsig_vs_fdr0.05_pearson_mat_bool_filt)[1]){
	max.cor.num<-dim(nonsig_vs_fdr0.05_pearson_mat_bool_filt)[1]
	}
	nonsig_vs_fdr0.05_pearson_mat_bool_filt<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[1:max.cor.num,]
	
	mz_rnames<-mz_rnames[1:max.cor.num]
	rnames<-rnames[1:max.cor.num]
	}

	
    
    pdfname<-paste(networkscope,"network_plot.pdf",sep="")
    pdf(pdfname,width=8,height=10)

    
    
	
	dup_ind<-which(duplicated(rnames)==TRUE)
	if(length(dup_ind)>0){
	nonsig_vs_fdr0.05_pearson_mat_bool_filt_1<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[-which(duplicated(rnames)==TRUE),]
	rnames<-rnames[-which(duplicated(rnames)==TRUE)]
	mz_rnames<-mz_rnames[-which(duplicated(rnames)==TRUE)]
	
	}else{
		nonsig_vs_fdr0.05_pearson_mat_bool_filt_1<-nonsig_vs_fdr0.05_pearson_mat_bool_filt
	}
    
    dup_indB<-which(duplicated(cnames)==TRUE)
    if(length(dup_indB)>0){
        nonsig_vs_fdr0.05_pearson_mat_bool_filt_1<-nonsig_vs_fdr0.05_pearson_mat_bool_filt_1[,-which(duplicated(cnames)==TRUE)]
        cnames<-cnames[-which(duplicated(cnames)==TRUE)]
        mz_cnames<-mz_cnames[-which(duplicated(cnames)==TRUE)]
        
    }
    
	set.seed(netrandseed)
    
    #save(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1,file="nonsig_vs_fdr0.05_pearson_mat_bool_filt_1.Rda")
    
    
	net_result<-try(network(mat=as.matrix(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1), threshold=abs.cor.thresh,color.node = net_node_colors,
    shape.node = c("rectangle", "circle"),
	color.edge = c("red", "blue"), lwd.edge = 1,
    show.edge.labels = FALSE, interactive = FALSE,cex.node.name=0.6),silent=TRUE)
    
    
    if(is(net_result,"try-error")){
        
       set.seed(netrandseed)
        net_result<-network(mat=as.matrix(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1), cutoff=abs.cor.thresh,color.node = net_node_colors,
        shape.node = c("rectangle", "circle"),
        color.edge = c("red", "blue"), lwd.edge = 1,
        show.edge.labels = FALSE, interactive = FALSE,cex.node.name=0.6) #,silent=TRUE)
        
       
    }

   
	cytoscape_fname<-paste("network_Cytoscape_format_maxcor",max.cor.num,"_rowcolnumlabels.gml",sep="")
	write.graph(net_result$gR, file =cytoscape_fname, format = "gml")

    if(net_legend==TRUE){
    print(legend("bottomright",c("Row #","Column #"),pch=c(22,19),col=net_node_colors, cex=0.9,title="Network matrix values:"))
	}
	

	
    
    
	try(dev.off(),silent=TRUE)
	
	
	}else{
	if(networkscope=="all"){
	print(paste("Metabolome-wide correlation network can not be generated as the correlation threshold criteria is not met.",sep=""))
	}else{
	print(paste("Targeted correlation network can not be generated as the correlation threshold criteria is not met.",sep=""))
	}
	
	}
	
	}

	}else{
	if(length(nonsig_vs_fdr0.05_pearson_mat_bool_filt)==dim(goodfeats)[1]){
	
	#print("here")
	
		rnames<-rownames(nonsig_vs_fdr0.05_pearson_mat_bool)
		rnames1<-rnames[-bad_index]
		nonsig_vs_fdr0.05_pearson_mat_bool_filt<-as.matrix(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
		nonsig_vs_fdr0.05_pearson_mat_bool_filt<-t(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
		rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-as.character(rnames1)
		check_cor<-max(abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt))
		
		fname<-paste("significant_correlations_",networktype,"_mzlabels.txt",sep="")
	
    #nonsig_vs_fdr0.05_pearson_mat_bool_filt<-round(nonsig_vs_fdr0.05_pearson_mat_bool_filt,2)
        
		write.table(nonsig_vs_fdr0.05_pearson_mat_bool_filt,file=fname,sep="\t",row.names=TRUE)
		
	fname<-paste("significant_correlations_",networktype,"CIRCOSformat_mzlabels.txt",sep="")
	
	mz_rnames<-rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	mz_cnames<-colnames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	#rnames<-c("Data",rnames)
	
	circos_format<-abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	
    #circos_format<-round(circos_format,2)
    
	#circos_format<-rbind(cnames,circos_format)
	circos_format<-cbind(rnames,circos_format)
	
    
    
	write.table(circos_format,file=fname,sep="\t",row.names=FALSE)
	
	
#	print("here")
	rnames<-mz_rnames
	cnames<-mz_cnames
	
	#cnames<-round(as.numeric(cnames),5)
	#rnames<-round(as.numeric(rnames),5)
	
	cnames<-seq(1,length(cnames))
	rnames<-seq(1,length(rnames))
    
    id_mapping_mat<-cbind(rnames,mz_rnames)
    
    #id_mapping_mat<-rbind(id_mapping_mat,cbind(cnames,mz_cnames))
    # colnames(id_mapping_mat)<-c("ID","Name")
    #write.csv(id_mapping_mat,file="node_id_mapping.csv",row.names=FALSE)
	
	colnames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-paste("Y",cnames,sep="")
	rownames(nonsig_vs_fdr0.05_pearson_mat_bool_filt)<-paste("X",rnames,sep="")
	
	fname<-paste("significant_correlations_",networktype,"CIRCOS_format_rowcolnumlabels.txt",sep="")
	
	circos_format<-abs(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
    #circos_format<-round(circos_format,2)
    
	#circos_format<-rbind(cnames,circos_format)
	circos_format<-cbind(rnames,circos_format)
    
    
	
	write.table(circos_format,file=fname,sep="\t",row.names=FALSE)
	
		fname<-paste("significant_correlations_",networktype,"matrix_rowcolnumlabels.txt",sep="")
	
    #  nonsig_vs_fdr0.05_pearson_mat_bool_filt<-round(nonsig_vs_fdr0.05_pearson_mat_bool_filt,2)
    
		write.table(nonsig_vs_fdr0.05_pearson_mat_bool_filt,file=fname,sep="\t",row.names=TRUE)
	
		if(check_cor>=abs.cor.thresh){
	

	#pdf("network_plot.pdf",width=9,height=11)	
	
    pdfname<-paste(networkscope,"network_plot.pdf",sep="")
    pdf(pdfname,width=8,height=10)



#pdfname<-paste(networkscope,"network_plot.tiff",sep="")
#tiff(pdfname,res=300)

	#tiff("network_allrows_sigcols.tiff", width=plots.width,height=plots.height,res=plots.res, compression="lzw")
	#par_rows=1
	#par(mfrow=c(par_rows,1))
	nonsig_vs_fdr0.05_pearson_mat_bool_filt_1<-nonsig_vs_fdr0.05_pearson_mat_bool_filt[-which(duplicated(rnames)==TRUE),]
	set.seed(netrandseed)
	net_result<-try(network(mat=as.matrix(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1), threshold=abs.cor.thresh,color.node = net_node_colors,shape.node = c("rectangle", "circle"),
	color.edge = c("red", "blue"), lwd.edge = 1,show.edge.labels = FALSE, interactive = FALSE,cex.node.name=0.6),silent=TRUE)
    
    if(is(net_result,"try-error")){
        
       
        net_result<-try(network(mat=as.matrix(nonsig_vs_fdr0.05_pearson_mat_bool_filt_1), cutoff=abs.cor.thresh,color.node = net_node_colors,
        shape.node = c("rectangle", "circle"),
        color.edge = c("red", "blue"), lwd.edge = 1,
        show.edge.labels = FALSE, interactive = FALSE,cex.node.name=0.6),silent=TRUE)
    }
    
    print(net_result)
    
	if(net_legend==TRUE){
	 print(legend("bottomright",c("Row #","Colum #"),pch=c(22,19),col=net_node_colors, cex=0.9,title="Network matrix values:"))
	}
	#write.graph(net_result$gR, file = "network_cytoscape_format.gml", format = "gml")
	
	cytoscape_fname<-paste("network_Cytoscape_format_maxcor",max.cor.num,"_rowcolnumlabels.gml",sep="")
	write.graph(net_result$gR, file =cytoscape_fname, format = "gml")
    #dev.off()
	
    

        
        
    try(dev.off(),silent=TRUE)
	
	}
		
	}else{
	print("No significant correlations found.")
	}
	}
	
    # save(net_result,file="metabnet.Rda")
    
		return(nonsig_vs_fdr0.05_pearson_mat_bool_filt)
	
	
	}
