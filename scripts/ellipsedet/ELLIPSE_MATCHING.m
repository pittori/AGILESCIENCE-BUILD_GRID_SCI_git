% Naive matching
% Change fname1 and fname2 

clear all
close all
clc

fname1   = 'ABPH3_100_50000_FF7.ell';
fname2   = '3FGL_FermiLAT.ell';

outfname = 'ABPH3_100_50000_FF7.assoc';

e1 = ellload(fname1);
e2 = ellload(fname2);

fid = fopen(outfname, 'w');
fid2 = fopen('notincluded', 'w')
fid3 = fopen('ABPH3_100_50000_FF7.includedlist', 'w')
fid4 = fopen('errorlist', 'w')

fprintf(fid, 'Match %s with %s\n', fname1, fname2)

for i = 1 : length(e1)
  
    fprintf(fid, '[%05d] %s\n', i, e1(i).name);

    included = 0;    
    errmsg = 0;
    for j = 1 : length(e2)
       
        % Check if overlapping is possible using radius
        dx = e2(j).x - e1(i).x;
        dy = e2(j).y - e1(i).y;
        d  = sqrt(dx^2 + dy^2);
        
        % Accurate overlapping
        if d <= e2(j).r + e1(i).r
            
            if isempty(e1(i).C)
                [e1(i).C,e1(i).D,e1(i).R,e1(i).M] = ellmatrix(e1(i).x, e1(i).y, e1(i).a, e1(i).b, e1(i).p);
            end
            
            if isempty(e2(j).C)
                [e2(j).C,e2(j).D,e2(j).R,e2(j).M] = ellmatrix(e2(j).x, e2(j).y, e2(j).a, e2(j).b, e2(j).p);
            end
            
            res = elltest(e1(i).C, e1(i).D, e1(i).R, e1(i).M, e2(j).C, e2(j).D, e2(j).R, e2(j).M, 1e-6);
            
            %fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
            
            switch res
                
                case 0
                    
                    %fprintf(fid, ' not overlap\n');
                    
                case 1
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' tangent external\n');
                    included = included + 1;
   
                case 2
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' overlap\n');
		    		included = included + 1;
                    
                case 3
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' equal\n');
		    		included = included + 1;
	                    
                case 4
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' tangent contained\n');
		   		  	included = included + 1;
                
                case 5
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' contained\n');
		    		included = included + 1;
                    
                otherwise
                    fprintf(fid, '  ## [%05d] %s', j, e2(j).name);
                    fprintf(fid, ' error\n');
		    		% included = included + 1;
                    errmsg = 1
            end
            
	  
        end
        
        
    end
    if included == 0
        fprintf(fid2, '%s\n', e1(i).name);
    end
    
    fprintf(fid3, '%s %i\n', e1(i).name, included);
  
    if errmsg > 0
    	fprintf(fid4, '%s\n', e1(i).name);
    end
    
end

fclose(fid);
fclose(fid2);
fclose(fid3);
fclose(fid4);
