function res=target_fun3(x,crd_md,crd,crd_cnt)
    mr_hgt=8-x(2).*log(crd(:,1))-x(3).*exp(-crd_md(:));
    mr_wdt=mr_hgt;
    % ins_hgt=5+x(1).*(1-exp(-crd(:,1)./100));
    res=sum(mr_hgt(1:crd_cnt).*mr_wdt(1:crd_cnt));
end