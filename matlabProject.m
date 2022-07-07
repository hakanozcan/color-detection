% HAKAN ÖZCAN - 13253043
%Video görüntü aracýlýðýyla RGB renk tespiti

%Renklerin eþik deðerlerini(threshold) tanýmladým. Bu deðerlere daha önce
%hesaplanmýþ renk eþiði deðerlerinden yardým alarak ulaþtým


kirmiziEsik = 0.24;
yesilEsik = 0.05; 
maviEsik = 0.15; 


%kamerayý tanýmladýk

kamera = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... 
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
video = imaqhwinfo(kamera); % giriþ videosunu deðiþkene atadýk
kare = vision.BlobAnalysis('AreaOutputPort', false, ... %bu noktada yakalanan karelerin büyüklüðü ve sayýsýný tanýmladýk
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 500, ... %bu kýsým yakalanan karelerin büyüklüðünün alan bazýnda tanýmlandýðý kýsým.  500-3000 arasýnda tuttum tanýmlanan bölgeyi
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10); %en fazla 10 kare yakalasýn istiyoruz
kutu = vision.ShapeInserter('BorderColorSource', 'Input port', ... % sol üstteki sayacý tanýmlýyoruz ve içindeki bilgileri giriyoruz
                                        'Fill', true, ...
                                        'FillColorSource', 'Input port', ...
                                        'Opacity', 0.4);
kutuKirmizi = vision.TextInserter('Text', 'Kirmizi : %2d', ... 
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ...  %sayaç bilgisi (kýrmýzý)
                                    'Font', 'Verdana', ...
                                    'FontSize', 14);
kutuYesil = vision.TextInserter('Text', 'Yesil : %2d', ... 
                                    'Location',  [5 18], ...
                                    'Color', [0 1 0], ... %sayaç bilgisi (yesil)
                                    'Font', 'Verdana', ...
                                    'FontSize', 16);
kutuMavi = vision.TextInserter('Text', 'Mavi : %2d', ... 
                                    'Location',  [5 34], ...
                                    'Color', [0 0 1], ... %sayaç bilgisi (mavi)
                                    'Font', 'Verdana', ...
                                    'FontSize', 16);
kutuOrta = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % bu kýsým da nesnenin koordinatlarýný gösteriyor
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... %sarý renk yaptýk
                                    'Font', 'Courier New', ...
                                    'FontSize', 16);
input = vision.VideoPlayer('Name', 'Video Renk Tanimlama', ... %çýkýþ videosunun ayarlarý
                                'Position', [100 100 video.MaxWidth+20 video.MaxHeight+30]);
fps = 0; % saniyedeki kare sayýsýný yani fps'yi tanýmlýyoruz bir deðiþkene

while(fps < 3000) %bu döngüde fps limiti tercihen deðiþtirilebilir ben uzun süre ekranda kalmasý için 3000 yaptým. eðer düþük bir rakam tercih edilirse kare sýnýrý dolduðu zaman döngü biteceði için video donar.
    kareYakala = step(kamera); % tek kareyi yakaladýðýmýz fonksiyon
    kareYakala = flip(kareYakala,2); %kareyi göstermek için ayna görüntüsünü aldýðýmýz fonksiyon
     
    kirmiziYakala = imsubtract(kareYakala(:,:,1), rgb2gray(kareYakala)); % görüntünün kýrmýzý bileþenini aldýk
    kirmiziYakala = medfilt2(kirmiziYakala, [3 3]); % medyan filtreyle gürültü azalttýk
    kirmiziCevir = im2bw(kirmiziYakala, kirmiziEsik); % bu þekilde renk tanýmlamasýný daha kolay yapabileceðimiz için binary olarak çeviriyoruz 
    
    yesilYakala = imsubtract(kareYakala(:,:,2), rgb2gray(kareYakala)); 
    yesilYakala = medfilt2(yesilYakala, [3 3]); 
    yesilCevir = im2bw(yesilYakala, yesilEsik); 
    
    maviYakala = imsubtract(kareYakala(:,:,3), rgb2gray(kareYakala)); 
    maviYakala = medfilt2(maviYakala, [3 3]); 
    maviCevir = im2bw(maviYakala, maviEsik); 
    
    [koseKirmizi, sinirKirmizi] = step(kare, kirmiziCevir); % kýrmýzý rengi yakaladýðýmýzda çýkacak olan þeklin köþeleri ve sýnýrlarýný belirliyoruz
    koseKirmizi = uint16(koseKirmizi); % daha sonra bunlarý integer deðer olarak döndürüyoruz 
    
    [koseYesil, sinirYesil] = step(kare, yesilCevir); 
    koseYesil = uint16(koseYesil); 
    
    [koseMavi, sinirMavi] = step(kare, maviCevir); 
    koseMavi = uint16(koseMavi); 
    
    kareYakala(1:60,1:110,:) = 0; %bu kýsým sol üstteki sayaç için. belirgin olmasý için arka planý siyah yaptýk 
    videoGiris = step(kutu, kareYakala, sinirKirmizi, single([1 0 0])); 
    videoGiris = step(kutu, videoGiris, sinirYesil, single([0 1 0])); 
    videoGiris = step(kutu, videoGiris, sinirMavi, single([0 0 1])); 
    for object = 1:1:length(sinirKirmizi(:,1)) % kýrmýzý renge karþýlýk gelen köþeleri yazýyoruz
        xKirmizi = koseKirmizi(object,1); yKirmizi = koseKirmizi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xKirmizi yKirmizi], [xKirmizi-6 yKirmizi-9]); 
    end
    for object = 1:1:length(sinirYesil(:,1)) % yeþil renge karþýlýk gelen köþeleri yazýyoruz
        xYesil = koseYesil(object,1); yYesil = koseYesil(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xYesil yYesil], [xYesil-6 yYesil-9]); 
    end
    for object = 1:1:length(sinirMavi(:,1)) % mavi renge karþýlýk gelen köþeleri yazýyoruz
        xMavi = koseMavi(object,1); yMavi = koseMavi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xMavi yMavi], [xMavi-6 yMavi-9]); 
    end
    videoGiris = step(kutuKirmizi, videoGiris, uint8(length(sinirKirmizi(:,1)))); % bu kýsým kýrmýzý renkleri sayýyor
    videoGiris = step(kutuYesil, videoGiris, uint8(length(sinirYesil(:,1)))); % yeþil
    videoGiris = step(kutuMavi, videoGiris, uint8(length(sinirMavi(:,1)))); % mavi
    step(input, videoGiris); % çýkýþ videosu
    fps = fps+1;
end

release(input); 
release(kamera);
clc;