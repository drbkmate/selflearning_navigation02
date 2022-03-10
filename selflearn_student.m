
prompt = 'Clear ruleTable? [Y/N]';
str = input(prompt,'s');
if(upper(str)=='N')
    clearvars -except ruleTable
    disp(ruleTable)
else
    clear all;
    disp('ruleTable empty')
end
close all;

%% Basemaps
map=imread('32d.png');

%% "defines"
%cell values
emptyVal=0;
finishVal=-1;
robotVal=-2;
pathVal=-2.5;
obstacleVal=-3;

%rule table size (movement and direction possibilities - min: 4x4)
directions=4;
movements=4;

%directions (where is the finish cell)
dirRight=1;
dirLeft=2;
dirUp=3;
dirDown=4;

%movements (where to move)
moveRight=1;
moveLeft=2;
moveUp=3;
moveDown=4;

if (exist('ruleTable')==0)    
    ruleTable=zeros(directions,movements);
end

%% get start and finish positions
%find R
startPos=[-1,-1]; %invalid
for i=1:size(map,1)
    for j=1:size(map,2)
        if reshape(map(i,j,:),[1 3])==[255,0,0] %red
            startPos=[i,j];
        end
    end
end

%find F
finishPos=[-1,-1]; %invalid
for i=1:size(map,1)
    for j=1:size(map,2)
        if reshape(map(i,j,:),[1 3])==[0,255,0] %green
            finishPos=[i,j];
        end
    end
end

disp(['start coords: ', num2str(startPos)]);
disp(['finish coords: ', num2str(finishPos)]); 

%% Replace start, finish, obstacle cell values
map=rgb2gray(map);
map=1-im2double(map);
map(finishPos(1), finishPos(2))=finishVal; %finish
map(startPos(1), startPos(2))=robotVal; %start
for i=1:size(map,1)
    for j=1:size(map,2)
        if map(i,j)==1
            map(i,j)=obstacleVal; %obstacle
        end
    end
end

%% let's learn!
robotPos=startPos;

while(norm(robotPos)~=norm(finishPos)) %norm = norma, alapvetően a 2-est használja --> 2d vektor
   
    newPos=robotPos;
    directionIndex=-1; %sort muttat meg
 
    % 1. feladat  
    %directionIndex, azaz a robothoz képest a cél irányának meghatározása 
    %directions 
    % dirRight=1;
    % dirLeft=2;
    % dirUp=3;
    % dirDown=4;
    if(abs(robotPos(1)-finishPos(1))>abs(robotPos(2)-finishPos(2)))
        if(robotPos(1)>finishPos(1))
            directionIndex=dirUp;
        else
            directionIndex=dirDown;
        end
    else
        if(robotPos(2)>finishPos(2))
            directionIndex=dirLeft;
        else
            directionIndex=dirRight;
        end
    end
    
    
    disp(directionIndex)
    
    % 2. feladat
    %movementIndex, azaz az adott irányhoz tartozó legnagyobb jóságú lépés
    %kiválasztása a szabálytáblából
    %movements (lépések, merre léphetünk?)
    % moveRight=1;
    % moveLeft=2;
    % moveUp=3;
    % moveDown=4;
    [maxRuleVal, movementIndex] = max(ruleTable(directionIndex,:));
    
    
    % 3. feladat   
    %az új lépés kiszámítása, azaz "newPos" változó sorának ill.
    %oszlopának inkrementálása ill. dekrementálása
    switch(movementIndex)
        case moveRight
          newPos(2)=newPos(2)+1;
        case moveLeft
          newPos(2)=newPos(2)-1; 
        case moveUp
          newPos(1)=newPos(1)-1;
        case moveDown
          newPos(1)=newPos(1)+1;
    end
    
  
    
    % 4. feladat
    %távolság ellenõrzése, ha közeledtünk => szabály megerõsítése, ha
    %távolodtunk => szabály lerontása

    oldDistance=norm(robotPos-finishPos);
    newDistance=norm(newPos-finishPos);
    if(oldDistance>newDistance)
        ruleTable(directionIndex,movementIndex)=maxRuleVal+1;
    else
        ruleTable(directionIndex,movementIndex)=maxRuleVal-30;
    end
        
    
    %display movement
    
    if (map(newPos(1),newPos(2))==emptyVal) || (map(newPos(1),newPos(2))==finishVal)
        map(robotPos(1),robotPos(2))=pathVal;
        prevPos=robotPos;
        robotPos=newPos;
        map(robotPos(1),robotPos(2))=robotVal;
    else
        map(robotPos(1),robotPos(2))=pathVal;
        [robotPos,prevPos]=deal(prevPos,robotPos);
        map(robotPos(1),robotPos(2))=robotVal;
    end
    
    disp(ruleTable);
    imagesc(map);
    colormap(jet);
    pause(0.2);

 end

 %% Retry    
prompt = 'Retry? [Y/N]';
str = input(prompt,'s');
if(upper(str)=='Y')
    selflearn_student
end
