% HAKAN �ZCAN - 13253043
%Video g�r�nt� arac�l���yla RGB renk tespiti

%Renklerin e�ik de�erlerini(threshold) tan�mlad�m. Bu de�erlere daha �nce
%hesaplanm�� renk e�i�i de�erlerinden yard�m alarak ula�t�m


kirmiziEsik = 0.24;
yesilEsik = 0.05; 
maviEsik = 0.15; 


%kameray� tan�mlad�k

kamera = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... 
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
video = imaqhwinfo(kamera); % giri� videosunu de�i�kene atad�k
kare = vision.BlobAnalysis('AreaOutputPort', false, ... %bu noktada yakalanan karelerin b�y�kl��� ve say�s�n� tan�mlad�k
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 500, ... %bu k�s�m yakalanan karelerin b�y�kl���n�n alan baz�nda tan�mland��� k�s�m.  500-3000 aras�nda tuttum tan�mlanan b�lgeyi
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10); %en fazla 10 kare yakalas�n istiyoruz
kutu = vision.ShapeInserter('BorderColorSource', 'Input port', ... % sol �stteki sayac� tan�ml�yoruz ve i�indeki bilgileri giriyoruz
                                        'Fill', true, ...
                                        'FillColorSource', 'Input port', ...
                                        'Opacity', 0.4);
kutuKirmizi = vision.TextInserter('Text', 'Kirmizi : %2d', ... 
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ...  %saya� bilgisi (k�rm�z�)
                                    'Font', 'Verdana', ...
                                    'FontSize', 14);
kutuYesil = vision.TextInserter('Text', 'Yesil : %2d', ... 
                                    'Location',  [5 18], ...
                                    'Color', [0 1 0], ... %saya� bilgisi (yesil)
                                    'Font', 'Verdana', ...
                                    'FontSize', 16);
kutuMavi = vision.TextInserter('Text', 'Mavi : %2d', ... 
                                    'Location',  [5 34], ...
                                    'Color', [0 0 1], ... %saya� bilgisi (mavi)
                                    'Font', 'Verdana', ...
                                    'FontSize', 16);
kutuOrta = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % bu k�s�m da nesnenin koordinatlar�n� g�steriyor
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... %sar� renk yapt�k
                                    'Font', 'Courier New', ...
                                    'FontSize', 16);
input = vision.VideoPlayer('Name', 'Video Renk Tanimlama', ... %��k�� videosunun ayarlar�
                                'Position', [100 100 video.MaxWidth+20 video.MaxHeight+30]);
fps = 0; % saniyedeki kare say�s�n� yani fps'yi tan�ml�yoruz bir de�i�kene

while(fps < 3000) %bu d�ng�de fps limiti tercihen de�i�tirilebilir ben uzun s�re ekranda kalmas� i�in 3000 yapt�m. e�er d���k bir rakam tercih edilirse kare s�n�r� doldu�u zaman d�ng� bitece�i i�in video donar.
    kareYakala = step(kamera); % tek kareyi yakalad���m�z fonksiyon
    kareYakala = flip(kareYakala,2); %kareyi g�stermek i�in ayna g�r�nt�s�n� ald���m�z fonksiyon
     
    kirmiziYakala = imsubtract(kareYakala(:,:,1), rgb2gray(kareYakala)); % g�r�nt�n�n k�rm�z� bile�enini ald�k
    kirmiziYakala = medfilt2(kirmiziYakala, [3 3]); % medyan filtreyle g�r�lt� azaltt�k
    kirmiziCevir = im2bw(kirmiziYakala, kirmiziEsik); % bu �ekilde renk tan�mlamas�n� daha kolay yapabilece�imiz i�in binary olarak �eviriyoruz 
    
    yesilYakala = imsubtract(kareYakala(:,:,2), rgb2gray(kareYakala)); 
    yesilYakala = medfilt2(yesilYakala, [3 3]); 
    yesilCevir = im2bw(yesilYakala, yesilEsik); 
    
    maviYakala = imsubtract(kareYakala(:,:,3), rgb2gray(kareYakala)); 
    maviYakala = medfilt2(maviYakala, [3 3]); 
    maviCevir = im2bw(maviYakala, maviEsik); 
    
    [koseKirmizi, sinirKirmizi] = step(kare, kirmiziCevir); % k�rm�z� rengi yakalad���m�zda ��kacak olan �eklin k��eleri ve s�n�rlar�n� belirliyoruz
    koseKirmizi = uint16(koseKirmizi); % daha sonra bunlar� integer de�er olarak d�nd�r�yoruz 
    
    [koseYesil, sinirYesil] = step(kare, yesilCevir); 
    koseYesil = uint16(koseYesil); 
    
    [koseMavi, sinirMavi] = step(kare, maviCevir); 
    koseMavi = uint16(koseMavi); 
    
    kareYakala(1:60,1:110,:) = 0; %bu k�s�m sol �stteki saya� i�in. belirgin olmas� i�in arka plan� siyah yapt�k 
    videoGiris = step(kutu, kareYakala, sinirKirmizi, single([1 0 0])); 
    videoGiris = step(kutu, videoGiris, sinirYesil, single([0 1 0])); 
    videoGiris = step(kutu, videoGiris, sinirMavi, single([0 0 1])); 
    for object = 1:1:length(sinirKirmizi(:,1)) % k�rm�z� renge kar��l�k gelen k��eleri yaz�yoruz
        xKirmizi = koseKirmizi(object,1); yKirmizi = koseKirmizi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xKirmizi yKirmizi], [xKirmizi-6 yKirmizi-9]); 
    end
    for object = 1:1:length(sinirYesil(:,1)) % ye�il renge kar��l�k gelen k��eleri yaz�yoruz
        xYesil = koseYesil(object,1); yYesil = koseYesil(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xYesil yYesil], [xYesil-6 yYesil-9]); 
    end
    for object = 1:1:length(sinirMavi(:,1)) % mavi renge kar��l�k gelen k��eleri yaz�yoruz
        xMavi = koseMavi(object,1); yMavi = koseMavi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xMavi yMavi], [xMavi-6 yMavi-9]); 
    end
    videoGiris = step(kutuKirmizi, videoGiris, uint8(length(sinirKirmizi(:,1)))); % bu k�s�m k�rm�z� renkleri say�yor
    videoGiris = step(kutuYesil, videoGiris, uint8(length(sinirYesil(:,1)))); % ye�il
    videoGiris = step(kutuMavi, videoGiris, uint8(length(sinirMavi(:,1)))); % mavi
    step(input, videoGiris); % ��k�� videosu
    fps = fps+1;
end

release(input); 
release(kamera);
clc;