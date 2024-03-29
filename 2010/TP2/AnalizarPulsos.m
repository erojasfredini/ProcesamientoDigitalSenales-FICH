function [ sequencia ] = AnalizarPulsos( archivo, ploted)
%Analiza una secuencia de pulsos

%     S = load('se�al telefonica.txt', '-ascii' );
%     wavwrite(S,11025,'telefono');
%     
%     return;
    [datos,F] = wavread(archivo);
    if ploted == true
        plot(datos);
    end
        
    %variable independiente de funciones de numeros
    k= 0:1/F:length(datos)/F;
    %sequencia de numeros apretados
    sequencia = zeros(7,1);
    %numeros combinando frequencias de las filas y columnas
    numeros = zeros(12,length(k));
    
    %llenar numeros con las frequencias
    for i=1:4
        for j=1:3
            fq1=0;
            fq2=0;
            switch i
                case 1%fila1
                    fq1= 697;
                case 2%fila2
                    fq1= 770;
                case 3%fila3
                    fq1= 852;
                case 4%fila4
                    fq1= 941;
            end
            switch j
                case 1%columna1
                    fq2= 1209;
                case 2%columna2
                    fq2= 1336;
                case 3%columna3
                    fq2= 1477;
            end
            
            numeros((i-1)*3+j,:) = sin(2*pi*fq1*k) + sin(2*pi*fq2*k);
                
        end
    end
    
    
        %probando correlacion con un numero
%         Correlacion = zeros(12,1);
%         for i=1:12
%              CorrelacionTmp=zeros(1,50);
%              for w=1:50
%                  paso = uint32(697/25);
%                  CorrelacionTmp(1,w) = dot( datos , numeros(i,((w-1)*paso)+1:1:length(datos)+(w-1)*paso) ) / (norm( numeros(i,(w-1)*paso+1:length(datos)+(w-1)*paso))^2 );
%              end
%              Correlacion(i,1) = max(CorrelacionTmp);
%         end
    
    
    totPot = Potencia(datos);
       
        %Si se quiere que grafique los diagramas de potencias de sectores,
        %comparados con la potencia total de la se�al descomentar
    %GraficarPotenciaPorSector(datos,8000,totPot);
    
    %Comprobar las correlaciones
    k = 1;
    sequenciaIndex = 1;
    while k < length(datos)
     
        %Search pulse start
        if (k+500) > length(datos)
            break;
        end
        
        curPot = Potencia(datos(k:k+500));
        
        if curPot < (totPot*1.01)%el 1.01 es solo para que en la etapa de 
            k = k+1;             %fin de un pulso, que varia un poco
            continue;            %no tome una peque�a subida como otro pulso
        end                      %UN FACTOR PARA SONIDO LIMPIO ES 0.2
            
        w = k +1;
        %k = k-500;
        while w < length(datos)
            if (w+500) > length(datos)
                break;
            end
            curPot = Potencia(datos(w:w+500));
            if curPot > (totPot)%UN FACTOR PARA SONIDO LIMPIO ES 0.01
                w = w + 1;
                continue;
            else
                break;
            end
        end
        
        if (w+500) > length(datos)
            break;
        end
        %w = w +250;%fix
        %w = w +2000;%fix
        %k = k -400;%fix
        Pulse = datos(k:1:w);
        if ploted == true
            hold all;
            p = plot(k:1:w,Pulse);
            set(p,'Color','red','LineWidth',2);
        end
        
        k = w +1;%set next loop start
        
        Correlacion = zeros(12,1);
        for i=1:12
             CorrelacionTmp=zeros(1,50);
             for w=1:50
                 paso = uint32(697/25);
                 CorrelacionTmp(1,w) = dot( Pulse , numeros(i,((w-1)*paso)+1:length(Pulse)+(w-1)*paso) ) / (norm( numeros(i,(w-1)*paso+1:length(Pulse)+(w-1)*paso))^2 );
             end
             Correlacion(i,1) = max(CorrelacionTmp);
        end
        
        maximo = Correlacion(1);
        indice = 1;
        for i=2:12
            if Correlacion(i) > maximo
                maximo = Correlacion(i);
                indice = i;
            end
        end


        %sequencia(sequenciaIndex) = indice;
        switch indice
            case 10
                sequencia(sequenciaIndex) = '*';
            case 11
                sequencia(sequenciaIndex) = '0';
            case 12
                sequencia(sequenciaIndex) = '#';
            otherwise
             sequencia(sequenciaIndex) = '0'+indice;
        end
        sequenciaIndex = sequenciaIndex + 1;
        
    end
    
    sequencia = char(sequencia);

end


function res=Potencia(d)
    res =0;
    for i=1:length(d)
       res = res + d(i)^2;
    end

    res = res/length(d);
end

function GraficarPotenciaPorSector(datos,sector,PotenciaTotal)
    P = zeros(length(datos)-sector,1);
    for i=1:(length(datos)-sector)
        P(i) = Potencia(datos(i:i+sector));
    end
    plot(P);
    ylabel('Potencia');
    hold();
    p = plot( ones(1,length(P)) * PotenciaTotal);
    text(0,PotenciaTotal+(0.1*PotenciaTotal),'Potencia Total');
    set(p,'Color','red','LineWidth',2);
end

