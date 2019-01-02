function [ positions ] = hexagi_subplot_pos(plotwidth,plotheight,leftmargin,rightmargin,bottommargin,topmargin,nbx,nby,spacex,spacey)
% This function organises the subplots so there is less air between them etc. 
% Called from hexagi_plots_behavior_test.m

%%% --------------
% BRK flipped and transposed so that instead of reading up from bottom left, it reads right from top left. 
%
% Example:
%
% pageHeight = 21; % A4 paper
% pageWidth = 29.7;
% spCols = 2;
% spRows = 5;
% leftEdge = 1.5;
% rightEdge = 1.5;
% topEdge = 1.5;
% bottomEdge = 0.1;
% spaceX = 5;
% spaceY = 0.1;
% sub_pos = hexagi_subplot_pos(pageWidth,pageHeight,leftEdge,rightEdge,topEdge,bottomEdge,spCols,spRows,spaceX,spaceY);
% 
% figure;
% set(gcf,'PaperUnits','cent','PaperSize',[pageWidth pageHeight],'PaperPos',[0 0 pageWidth pageHeight]);
% 
% for i = 1:spRows
%     for j = 1:spCols
%         axes('pos',sub_pos{i,j});
%         imagesc(magic(5))
%         axis off
%     end
% end
%
%
%%% --------------

subxsize=(plotwidth-leftmargin-rightmargin-spacex*(nbx-1.0))/nbx;
subysize=(plotheight-topmargin-bottommargin-spacey*(nby-1.0))/nby;

for i=1:nbx
   for j=1:nby

       xfirst=leftmargin+(i-1.0)*(subxsize+spacex);
       yfirst=topmargin+(j-1.0)*(subysize+spacey);

       % BRK change
%            positions{i,j}=[xfirst/plotwidth yfirst/plotheight subxsize/plotwidth subysize/plotheight];
       positions{j,i}=[xfirst/plotwidth yfirst/plotheight subxsize/plotwidth subysize/plotheight];

   end
end

% BRK change    
positions = flipud(positions);
   
end