
function [BlobAngPrev] = BlobAngPrevComputation(BlobAng, BanglePrev)
% Compute BlobAngPrev based on the previous frame:
cond=0;
 try cond=~isempty(BlobAng-BanglePrev);
 catch
     cond=0;
 end
if cond==1
    if BanglePrev<=360 && BanglePrev>270 % Q=1
        if BlobAng>=0
            [m, ind]=min([abs(BlobAng+(360-BanglePrev)), abs((BlobAng+180)-BanglePrev)]);
            if ind==1
                BlobAngPrev = BlobAng;
            else
                BlobAngPrev = BlobAng+180;
            end
        elseif BlobAng<0
            [m, ind]=min([abs((360+BlobAng)-BanglePrev), abs((BlobAng+180)+(360-BanglePrev))]);
            if ind==1
                BlobAngPrev = 360+BlobAng;
            else
                BlobAngPrev = BlobAng+180;
            end
        end
    elseif  BanglePrev>=0 && BanglePrev<=90 % Q=2
         if BlobAng>=0
            [m, ind]=min([abs(BlobAng-BanglePrev), abs((180-BlobAng)+BanglePrev)]);
            if ind==1
                BlobAngPrev = BlobAng;
            else
                BlobAngPrev = 180-BlobAng;
            end
         elseif BlobAng<0
            [m, ind]=min([abs((360-(360+BlobAng))+BanglePrev), abs((180+BlobAng)-BanglePrev)]);
            if ind==1
                BlobAngPrev = 360+BlobAng;
            else
                BlobAngPrev = 180+BlobAng;
            end
         end
     
    elseif BanglePrev>90 && BanglePrev<=180 % Q=3
        if BlobAng>=0
            [m, ind]=min([abs(BlobAng-BanglePrev), abs((180+BlobAng)-BanglePrev)]);
            if ind==1
                BlobAngPrev = BlobAng;
            else
                BlobAngPrev = BlobAng+180;
            end
        elseif BlobAng<0
            [m, ind]=min([abs((360+BlobAng)-BanglePrev), abs((180+BlobAng)-BanglePrev)]);
          if ind==1
                BlobAngPrev = 360+BlobAng;
          else
                BlobAngPrev = 180+BlobAng;
          end
        end
    elseif BanglePrev>180 && BanglePrev<=270 % Q=4
        if BlobAng>=0
            [m, ind]=min([abs(BlobAng-BanglePrev), abs((180+BlobAng)-BanglePrev)]);
          if ind==1
                BlobAngPrev = BlobAng;
          else
                BlobAngPrev = 180+BlobAng;
          end
        elseif BlobAng<0
            [m, ind]=min([abs((360+BlobAng)-BanglePrev), abs((180+BlobAng)-BanglePrev)]);
          if ind==1
                BlobAngPrev = 360+BlobAng;
          else
                BlobAngPrev = 180+BlobAng;
          end
        end
    end
end
