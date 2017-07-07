function [nameCode] =  decodeName(st)
%this codee converts the name of the file to a binary code according to the
%following :
%bit1 =1 if is m else its 0
%
%     nameCode=[];
%     if(st(1)=='f')
%         nameCode=[nameCode 0];
%     else
%         nameCode=[nameCode 1];
%     end;
%     switch(st(3))
%         case 'a'
%             nameCode=[nameCode -1];
%             nameCode=[nameCode -1];
%             nameCode=[nameCode -1];
%         case 'b'
%             nameCode=[nameCode 1];
%             nameCode=[nameCode -1];
%             nameCode=[nameCode -1];
%         case 'f'
%             nameCode=[nameCode -1];
%             nameCode=[nameCode 1];
%             nameCode=[nameCode -1];
%         case 'j'
%             nameCode=[nameCode 1];
%             nameCode=[nameCode 1];
%             nameCode=[nameCode -1];
%         case 'n'
%             nameCode=[nameCode -1];
%             nameCode=[nameCode -1];
%             nameCode=[nameCode 1];
%         case 's'
%             nameCode=[nameCode 1];
%             nameCode=[nameCode -1];
%             nameCode=[nameCode 1];
%     end;
%     nameCode=nameCode';


% the main encoding for only 6 classes
% nameCode=[];
% switch(st(3))
%         case 'a'
%             nameCode=[1 0 0 0 0 0];
%         case 'b'
%             nameCode=[0 1 0 0 0 0];
%         case 'f'
%             nameCode=[0 0 1 0 0 0];
%         case 'j'
%             nameCode=[0 0 0 1 0 0];
%         case 'n'
%             nameCode=[0 0 0 0 1 0];
%         case 's'
%             nameCode=[0 0 0 0 0 1];
% end


%encoding for the 12 cases 
nameCode=[];
if(st(1)=='f')
    switch(st(3))
         case 'a'
            nameCode=[1 0 0 0 0 0 0 0 0 0 0 0 ];
         case 'b'
            nameCode=[0 1 0 0 0 0 0 0 0 0 0 0 ];
         case 'f'
             nameCode=[0 0 1 0 0 0 0 0 0 0 0 0 ];
         case 'j'
             nameCode=[0 0 0 1 0 0 0 0 0 0 0 0 ];
         case 'n'
             nameCode=[0 0 0 0 1 0 0 0 0 0 0 0 ];
         case 's'
             nameCode=[0 0 0 0 0 1 0 0 0 0 0 0 ];
     end;
else
    switch(st(3))
         case 'a'
            nameCode=[0 0 0 0 0 0 1 0 0 0 0 0 ];
         case 'b'
            nameCode=[0 0 0 0 0 0 0 1 0 0 0 0 ];
         case 'f'
             nameCode=[0 0 0 0 0 0 0 0 1 0 0 0 ];
         case 'j'
              nameCode=[0 0 0 0 0 0 0 0 0 1 0 0 ];
         case 'n'
             nameCode=[0 0 0 0 0 0 0 0 0 0 1 0 ];
         case 's'
             nameCode=[0 0 0 0 0 0 0 0 0 0 0 1 ];
     end;

end