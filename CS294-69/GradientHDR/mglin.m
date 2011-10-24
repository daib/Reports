function [ u ] = mglin( f, ncyles )

    NPRE = 1;
    NPOST = 1;
    
    n = size(f,1);
    
    nn = n;
    
    ng = -1;
    
    while nn > 0
        nn = floor(nn/2);
        ng = ng + 1;
    end
        
	%if (n != 1+(1L << ng)) printf("n-1 must be a power of 2 in mglin.");
	%if (ng > NGMAX) printf("increase NGMAX in mglin.");
	nn=floor(n/2)+1;
	ngrid=ng-1;
    
	%irho[ngrid]=dmatrix(1,nn,1,nn);
    
    %injf2c(irho[ngrid],u,nn);
    
    eval(['irho_' num2str(ngrid) ' = injf2c(f, nn);']);
    
	
    while nn > 3 
		nn = floor(nn/2) + 1;
		%injf2c(irho[ngrid],irho[ngrid+1],nn);
        ngrid = ngrid -1;
        eval(['irho_' num2str(ngrid) ' = injf2c(irho_' num2str(ngrid + 1) ', nn);']);
    end
	
	nn=3;
	irhs_1 = zeros(nn);
    iu_1 = slvsm(irho_1);
	ngrid=ng;
    for j=2:ngrid
		nn=2*nn-1;
		%eval(['iu_' num2str(j) = dmatrix(1,nn,1,nn);
		%irhs[j]=dmatrix(1,nn,1,nn);
		%ires[j]=dmatrix(1,nn,1,nn);
        
		%ctof(iu[j],iu[j-1],nn);
        eval(['iu_' num2str(j) ' = ctof(iu_' num2str(j-1) ', nn);']);
        
        % copy(irhs[j],(j != ngrid ? irho[j] : u),nn);
        if j ~= ngrid
            eval(['irhs_' num2str(j) ' = irho_' num2str(j) ';']);
        else
            eval(['irhs_' num2str(j) ' = f;']);
        end
        
		
        
        for jcycle=1:ncyles 
			nf=nn;
            for jj=j:-1:2 
                for jpre=1:NPRE
                    eval(['iu_' num2str(jj) ' = gsrelax(iu_' num2str(jj) ', irhs_' num2str(jj)  ', nf);']);
                end
                
                eval(['ires_' num2str(jj) ' = resid(iu_' num2str(jj) ', irhs_' num2str(jj) ', nf);']);
                nf=floor(nf/2)+1;
                eval(['irhs_' num2str(jj-1) ' = injf2c(ires_' num2str(jj) ', nf);']);
                eval(['iu_' num2str(jj-1) ' = zeros(nf);']);
            end
                
                
                %slvsm(iu[1],irhs[1]);
            iu_1 = slvsm(irhs_1);

            nf=3;
            for jj=2:j
                nf=2*nf-1;
                eval(['iu_' num2str(jj) ' = addint(iu_' num2str(jj) ', iu_' num2str(jj-1) ', nf);']);
                for jpost=1:NPOST
                    eval(['iu_' num2str(jj) ' = gsrelax(iu_' num2str(jj) ', irhs_' num2str(jj) ',nf);']);
                end
            end
                
            
        end
    end
	eval(['u = iu_' num2str(ngrid) ';']);

end

