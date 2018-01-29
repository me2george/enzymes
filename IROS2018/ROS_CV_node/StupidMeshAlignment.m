function [ best_pcl1_opt_vec, R ] = StupidMeshAlignment( P, Q, init_pcl1_opt_vec )
    P = DownsamplePCL(P,1000,1);
    pcl2 = P.v;
    Q_ds = DownsamplePCL(Q,1000,1);
    pcl1 = Q_ds.v;
    
    transl = init_pcl1_opt_vec(1:3);
    rot = GetEulRotMtx(init_pcl1_opt_vec(end-2:end));
    pcl1 = Apply3DTransfPCL(PointCloud(pcl1),rot);
    pcl1 = pcl1.v;
    pcl1 = pcl1 + transl;
    
    min_pcl1_opt_vec = init_pcl1_opt_vec - [0.1 0.1 0.1 pi pi pi];
    max_pcl1_opt_vec = zeros(1,6) + [0.1 0.1 0.1 pi pi pi];
    opt_options = optimset('Display','iter','TolX',1e-10,'TolFun',1e-10,'MaxIter',200,'MaxFunEvals',1000);
    [best_pcl1_opt_vec,~,~,~,~] = lsqnonlin(@(pcl1_opt_vec) StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2), init_pcl1_opt_vec, min_pcl1_opt_vec, max_pcl1_opt_vec, opt_options);
    % translate and rotate Q so it becomes R, the final, aligned pcl (ignoring segments)
    final_pcl = P.v + best_pcl1_opt_vec(1:3);
    R = PointCloud(final_pcl);
    R = Apply3DTransfPCL(R,rot);    
end

function avg_dist = StupidMeshAlignemtnOptFunc(pcl1_opt_vec, pcl1, pcl2)
    transl = pcl1_opt_vec(1:3);
    rot = GetEulRotMtx(pcl1_opt_vec(end-2:end));
    pcl1 = Apply3DTransfPCL(PointCloud(pcl1),rot);
    pcl1 = pcl1.v;
    pcl1 = pcl1 + transl;
    DIST=pdist2(pcl1,pcl2);
    min_dists1to2 = min(DIST,[],1);
    min_dists2to1 = min(DIST,[],2);
    avg_dist = (min_dists1to2' + min_dists2to1)/2;
end
