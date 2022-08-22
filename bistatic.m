classdef bistatic<handle
    properties
        HumanTopview
        time = 0
        deltaT = 1/10
        TX_Position = [1 1.3]
        RX_Position = [2.1 -1.2]
        TX_N = 4
        RX_N = 4
        Lambda = 0.005
        RangeGateNumber = 200
        RangeGateDistance = .1
        SimFinished = 0
        TimeEnd = 10
        targets
        signal
        Image_NW = 100
        Image_NH = 100
        image_x1 = -5
        image_x2 =  5
        image_y1 = -5
        image_y2 =  5
        TX_Pos
        RX_Pos
        ImX
        ImY
    end

    methods
        function obj = bistatic()
            obj.setTRXPos(1,1,1);
        end
        function setTRXPos(obj,txHV,rxHV,maxVA)
            obj.TX_Pos=[];
            aTX = 1;
            if maxVA
                aTX=obj.RX_N;
            end
            for m = 1:obj.TX_N
                obj.TX_Pos(m,:) = obj.TX_Position ;
                if txHV==1
                    obj.TX_Pos(m,1) = obj.TX_Pos(m,1) + aTX * (m-obj.TX_N/2) * obj.Lambda/2;
                else
                    obj.TX_Pos(m,2) = obj.TX_Pos(m,2) + aTX * (m-obj.TX_N/2) * obj.Lambda/2;
                end
            end
            obj.RX_Pos=[];

            for n = 1:obj.RX_N
                obj.RX_Pos(n,:) = obj.RX_Position ;
                if rxHV==1
                    obj.RX_Pos(n,1) = obj.RX_Pos(n,1) + (n-obj.TX_N/2) * obj.Lambda/2;
                else
                    obj.RX_Pos(n,2) = obj.RX_Pos(n,2) + (n-obj.TX_N/2) * obj.Lambda/2;
                end
            end
        end
        function CloudPoints = getCloudPoints(obj,image,Method,THR)
            CloudPoints =[];
            if Method == 1
                [imagex,imagey]  = find(abs(image)> THR*max(max(abs(image))));
                CloudPoints(:,1) = obj.ImX(imagex);
                CloudPoints(:,2) = obj.ImY(imagey);
            end
        end
        function image = getImage(obj)
            image = zeros(obj.Image_NW,obj.Image_NH);
            obj.ImX = linspace(obj.image_x1,obj.image_x2,obj.Image_NW);
            obj.ImY = linspace(obj.image_y1,obj.image_y2,obj.Image_NH);


            for i = 1:size(image,1)
                for j = 1:size(image,2)
                    pxy = [obj.ImX(i),obj.ImY(j)];
                    for m = 1:obj.TX_N
                        for n = 1:obj.RX_N
                            d = norm(pxy-obj.TX_Pos(m,:))+norm(pxy-obj.RX_Pos(n,:));
                            bp = 2*pi*(0:obj.RangeGateNumber-1);
                            bp = bp * d / (obj.RangeGateNumber*obj.RangeGateDistance);
                            bp=bp+2*pi/obj.Lambda*d;
                            bp = exp(1i*bp).';
                            sig = squeeze(obj.signal(m,n,:));
                            image(i,j)=image(i,j)+bp'*sig;

                        end
                    end

                end
            end
        end
        function signal = getSignal(obj)
            signal = zeros(obj.TX_N,obj.RX_N,obj.RangeGateNumber);
            for i = 1: length(obj.targets)
                for m = 1:obj.TX_N
                    for n = 1:obj.RX_N
                        for k = 1:size(obj.targets(i).Info.xy,1)
                            d = norm(obj.targets(i).Info.xy(k,:)-obj.TX_Pos(m,:))+norm(obj.targets(i).Info.xy(k,:)-obj.RX_Pos(n,:));
                            bp = 2*pi*(0:obj.RangeGateNumber-1);
                            bp = bp * d / (obj.RangeGateNumber*obj.RangeGateDistance) ;
                            bp=bp+2*pi/obj.Lambda*d;
                            signal(m,n,:)=signal(m,n,:)+reshape(exp(1i*bp),1,1,obj.RangeGateNumber);
                        end

                    end
                end
            end
        end
        function updateTime(obj)
            obj.time = obj.time + obj.deltaT;
            if obj.time>obj.TimeEnd
                obj.SimFinished=1;
            end
        end
        function PosInfo = updateTargetPosition(obj,Pos,MovementParameters)
            t = mod(obj.time,MovementParameters.T) + MovementParameters.t0;
            if MovementParameters.Model==1
                x = MovementParameters.a *cos(2*pi*t/MovementParameters.T);
                y = MovementParameters.b *sin(2*pi*t/MovementParameters.T);
                teps=1e-3;
                t = t + teps*obj.deltaT;
                x2 = MovementParameters.a *cos(2*pi*t/MovementParameters.T);
                y2 = MovementParameters.b *sin(2*pi*t/MovementParameters.T);
                vx = (x2-x)/(teps*obj.deltaT);
                vy = (y2-y)/(teps*obj.deltaT);
                dxy = obj.deltaT*[vx,vy];
                PosInfo.P = Pos + dxy;
                PosInfo.V = [vx,vy];
                PosInfo.dir = atan2(vy,vx);
            elseif MovementParameters.Model==2
            elseif MovementParameters.MovementModel==3
            elseif MovementParameters.MovementModel==4
            end
        end

        function rotatedImage = rotHuman(obj,angle)
            m=mean(obj.HumanTopview);
            rotatedImage=obj.HumanTopview-repmat(m,size(obj.HumanTopview,1),1);
            rotMat = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
            rotatedImage = rotatedImage*rotMat;
            rotatedImage=rotatedImage+repmat(m,size(obj.HumanTopview,1),1);
        end

        function readHumanTopview(obj,path,DownSampling,humanScale)
            [~,~,human] = imread(path);
            human = human(1:DownSampling:end,1:DownSampling:end)>0;
            [humanx,humany]  = find(human > 0);
            humanx = humanx-min(humanx);
            humany = humany-min(humany);
            maxxy = max([humanx;humany]);
            humanx=humanx/maxxy*humanScale;
            humany=humany/maxxy*humanScale;
            obj.HumanTopview =[humanx humany];
        end
    end
end

