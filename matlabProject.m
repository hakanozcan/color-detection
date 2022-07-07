%Video görüntü aracılığıyla RGB renk tespiti

%Renklerin eşik değerlerini(threshold) tanımladım. Bu değerlere daha önce
%hesaplanmış renk eşiği değerlerinden yardım alarak ulaştım


kirmiziEsik = 0.24;
yesilEsik = 0.05; 
maviEsik = 0.15; 


%kamerayı tanımladık

kamera = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ... 
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
video = imaqhwinfo(kamera); % giriş videosunu değişkene atadık
kare = vision.BlobAnalysis('AreaOutputPort', false, ... %bu noktada yakalanan karelerin büyüklüğü ve sayısını tanımladık
                                'CentroidOutputPort', true, ... 
                                'BoundingBoxOutputPort', true', ...
                                'MinimumBlobArea', 500, ... %bu kısım yakalanan karelerin büyüklüğünün alan bazında tanımlandığı kısım.  500-3000 arasında tuttum tanımlanan bölgeyi
                                'MaximumBlobArea', 3000, ...
                                'MaximumCount', 10); %en fazla 10 kare yakalasın istiyoruz
kutu = vision.ShapeInserter('BorderColorSource', 'Input port', ... % sol üstteki sayacı tanımlıyoruz ve içindeki bilgileri giriyoruz
                                        'Fill', true, ...
                                        'FillColorSource', 'Input port', ...
                                        'Opacity', 0.4);
kutuKirmizi = vision.TextInserter('Text', 'Kirmizi : %2d', ... 
                                    'Location',  [5 2], ...
                                    'Color', [1 0 0], ...  %sayaç bilgisi (kırmızı)
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
kutuOrta = vision.TextInserter('Text', '+      X:%4d, Y:%4d', ... % bu kısım da nesnenin koordinatlarını gösteriyor
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... %sarı renk yaptık
                                    'Font', 'Courier New', ...
                                    'FontSize', 16);
input = vision.VideoPlayer('Name', 'Video Renk Tanimlama', ... %çıkış videosunun ayarları
                                'Position', [100 100 video.MaxWidth+20 video.MaxHeight+30]);
fps = 0; % saniyedeki kare sayısını yani fps'yi tanımlıyoruz bir değişkene

while(fps < 3000) %bu döngüde fps limiti tercihen değiştirilebilir ben uzun süre ekranda kalması için 3000 yaptım. eğer düşük bir rakam tercih edilirse kare sınırı dolduğu zaman döngü biteceği için video donar.
    kareYakala = step(kamera); % tek kareyi yakaladığımız fonksiyon
    kareYakala = flip(kareYakala,2); %kareyi göstermek için ayna görüntüsünü aldığımız fonksiyon
     
    kirmiziYakala = imsubtract(kareYakala(:,:,1), rgb2gray(kareYakala)); % görüntünün kırmızı bileşenini aldık
    kirmiziYakala = medfilt2(kirmiziYakala, [3 3]); % medyan filtreyle gürültü azalttık
    kirmiziCevir = im2bw(kirmiziYakala, kirmiziEsik); % bu şekilde renk tanımlamasını daha kolay yapabileceğimiz için binary olarak çeviriyoruz 
    
    yesilYakala = imsubtract(kareYakala(:,:,2), rgb2gray(kareYakala)); 
    yesilYakala = medfilt2(yesilYakala, [3 3]); 
    yesilCevir = im2bw(yesilYakala, yesilEsik); 
    
    maviYakala = imsubtract(kareYakala(:,:,3), rgb2gray(kareYakala)); 
    maviYakala = medfilt2(maviYakala, [3 3]); 
    maviCevir = im2bw(maviYakala, maviEsik); 
    
    [koseKirmizi, sinirKirmizi] = step(kare, kirmiziCevir); % kırmızı rengi yakaladığımızda çıkacak olan şeklin köşeleri ve sınırlarını belirliyoruz
    koseKirmizi = uint16(koseKirmizi); % daha sonra bunları integer değer olarak döndürüyoruz 
    
    [koseYesil, sinirYesil] = step(kare, yesilCevir); 
    koseYesil = uint16(koseYesil); 
    
    [koseMavi, sinirMavi] = step(kare, maviCevir); 
    koseMavi = uint16(koseMavi); 
    
    kareYakala(1:60,1:110,:) = 0; %bu kısım sol üstteki sayaç için. belirgin olması için arka planı siyah yaptık 
    videoGiris = step(kutu, kareYakala, sinirKirmizi, single([1 0 0])); 
    videoGiris = step(kutu, videoGiris, sinirYesil, single([0 1 0])); 
    videoGiris = step(kutu, videoGiris, sinirMavi, single([0 0 1])); 
    for object = 1:1:length(sinirKirmizi(:,1)) % kırmızı renge karşılık gelen köşeleri yazıyoruz
        xKirmizi = koseKirmizi(object,1); yKirmizi = koseKirmizi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xKirmizi yKirmizi], [xKirmizi-6 yKirmizi-9]); 
    end
    for object = 1:1:length(sinirYesil(:,1)) % yeşil renge karşılık gelen köşeleri yazıyoruz
        xYesil = koseYesil(object,1); yYesil = koseYesil(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xYesil yYesil], [xYesil-6 yYesil-9]); 
    end
    for object = 1:1:length(sinirMavi(:,1)) % mavi renge karşılık gelen köşeleri yazıyoruz
        xMavi = koseMavi(object,1); yMavi = koseMavi(object,2);
        videoGiris = step(kutuOrta, videoGiris, [xMavi yMavi], [xMavi-6 yMavi-9]); 
    end
    videoGiris = step(kutuKirmizi, videoGiris, uint8(length(sinirKirmizi(:,1)))); % bu kısım kırmızı renkleri sayıyor
    videoGiris = step(kutuYesil, videoGiris, uint8(length(sinirYesil(:,1)))); % yeşil
    videoGiris = step(kutuMavi, videoGiris, uint8(length(sinirMavi(:,1)))); % mavi
    step(input, videoGiris); % çıkış videosu
    fps = fps+1;
end

release(input); 
release(kamera);
clc;
