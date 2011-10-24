function uc = injf2c( uf, nc )
%
% function uc = injf2c( uf )
%
% Transfers a fine grid to a coarse grid by injection
%
% Input
%   uf    fine-grid function
%
% Returns
%   uc   coarse-grid function
%
%[nrf,ncf] = size( uf );

% nrc = (nrf + 1)/2;
% ncc = (ncf + 1)/2;

nrc = 2 * nc - 1;
ncc = nrc;

uc = zeros(nrc, ncc);

jf = 3;
for jc=2:nc-1
    iif = 3;
    for ic=2:nc-1
        uc(ic,jc)=0.5*uf(iif,jf)+0.125*(uf(iif+1,jf)+uf(iif-1,jf)+uf(iif,jf+1)+uf(iif,jf-1));
        iif = iif+2;
    end
    
    jf = jf+2;
end

jc = 1;
for ic=1:nc
    uc(ic,1) = uf(jc,1);
    uc(ic,ncc) = uf(jc,ncc);
        
    jc = jc + 2;
end

jc=1;
for ic=1:nc
	uc(1,ic)=uf(1,jc);
	uc(nrc,ic)=uf(nrc,jc);
    jc = jc + 2;
end

