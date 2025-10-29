# VMware Workstation 17.6.4 Troubleshooting on Kernel 6.17.0-6

## Ortam Bilgisi

Bu dokümantasyon Ubuntu 25.10 Questing Quetzal x86_64 sisteminde çalışılarak oluşturulmuştur. Kullanılan kernel versiyonu 6.17.0-6-generic'tir. Sistem AMD64 mimarisi üzerinde test edilmiştir.

## Problem Tanımı

VMware Workstation 17.6.4 servisi başlatılamıyordu. Servis loglarında "Virtual machine monitor - failed" ve "Virtual ethernet - failed" hataları görünüyordu. systemctl status vmware komutu servisin failed durumda olduğunu gösteriyordu.

## Root Cause Analizi

Systematic debugging metodolojisi kullanılarak yapılan inceleme sonucunda asıl problemin kernel modüllerinin hiç build edilmemiş olduğu tespit edildi. vmmon ve vmnet kernel modüllerinin .ko dosyaları proje dizininde mevcut değildi ve dolayısıyla sistem modül dizinine de install edilmemişti. lsmod çıktısında bu modüller görünmüyordu ve modprobe ile yükleme denemesi "Module not found" hatası veriyordu.

Kernel headers kontrol edildiğinde /lib/modules/6.17.0-6-generic/build dizininin mevcut olduğu ve build işlemi için gerekli tüm dosyaların hazır olduğu görüldü. Bu durumda problemin sadece build ve install adımlarının yapılmamış olmasından kaynaklandığı anlaşıldı.

## Çözüm Süreci

İlk olarak proje dizininde clean işlemi yapıldı ve ardından modüller build edildi. Make clean komutu önceki build artifact'larını temizledi ve make komutu vmmon-only ve vmnet-only dizinlerinde kernel build system kullanarak modülleri derledi. Build işlemi sırasında bazı MIN ve MAX macro redefinition uyarıları alındı ancak bunlar kritik değildi ve derleme başarıyla tamamlandı.

Build işlemi tamamlandıktan sonra make install komutu kullanılarak modüller /lib/modules/6.17.0-6-generic/misc/ dizinine kopyalandı ve depmod -a komutuyla kernel module dependency güncellemesi yapıldı. Installation başarıyla tamamlandıktan sonra modprobe vmmon ve modprobe vmnet komutlarıyla modüller kernel'e yüklendi. Son olarak systemctl restart vmware komutuyla VMware servisi yeniden başlatıldı.

## Doğrulama

Çözümün başarılı olduğunu doğrulamak için birkaç kontrol yapıldı. lsmod çıktısında vmmon ve vmnet modüllerinin yüklendiği görüldü. systemctl status vmware komutu servisin active running durumda olduğunu gösterdi. modinfo vmmon komutuyla modül bilgileri kontrol edildiğinde filename değerinin doğru module path'i gösterdiği ve vermagic değerinin kernel versiyonuyla uyumlu olduğu teyit edildi.

## Gelecek Kernel Güncellemeleri İçin

Kernel güncellemesi yapıldığında modüllerin yeniden build edilmesi gerekecektir çünkü her kernel versiyonu kendi module dizinine sahiptir. Proje dizininde bulunan rebuild-vmware-modules.sh script'i bu işlemi otomatikleştirir. Alternatif olarak make reload komutu da kullanılabilir. Bu komut önce modülleri unload eder, sonra rebuild ve reinstall işlemlerini yapar ve son olarak modülleri tekrar yükleyerek VMware servisini restart eder.

## Teknik Detaylar

VMware Workstation 17.6.4 build-24832109 versiyonu kernel 6.17+ için bazı patch'ler içermektedir. vmmon modülünde timer API güncellemesi yapılmış ve del_timer_sync fonksiyon çağrıları timer_delete_sync ile değiştirilmiştir. Ayrıca MSR API güncellemesi yapılarak rdmsrl_safe fonksiyonu rdmsrq_safe ile değiştirilmiştir. VMMON_VERSION değeri 416'dan 417'ye yükseltilmiştir. vmnet modülünde ise dev_base_lock kullanımı kaldırılmıştır.

Bu patch'ler sayesinde modüller kernel 6.17.0-6-generic ile uyumlu şekilde derlenmekte ve çalışmaktadır. Build sırasında görülen compiler version uyarısı ve macro redefinition uyarıları functionality'yi etkilememektedir.

## Özet

VMware'in çalışmaması sorunu kernel modüllerinin build ve install edilmemesinden kaynaklanıyordu. make clean, make ve sudo make install komutlarıyla modüller derlendi ve yüklendi. modprobe ile modüller kernel'e eklendi ve VMware servisi başarıyla başlatıldı. Kernel güncellemelerinden sonra aynı adımların tekrarlanması gerektiği unutulmamalıdır.
