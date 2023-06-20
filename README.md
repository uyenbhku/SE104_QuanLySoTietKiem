# ĐỒ ÁN NHẬP MÔN CÔNG NGHỆ PHẦN MỀM - ĐỀ TÀI: QUẢN LÝ SỔ TIẾT KIỆM

### LỜI GIỚI THIỆU
Đây là đồ án cuối kỳ môn Nhập môn Công nghệ Phần mềm lớp SE104.N22, được thực hiện bởi nhóm 5 và dưới sự hướng dẫn của ThS. Đỗ Thị Thanh Tuyền.

#### Thành viên nhóm 5
|STT|Tên thành viên|MSSV|
|:-:|:-:|:-:|
|1|[Hoàng Anh Đức Đăng Quang](https://github.com/QuangHoang059)|21522509|
|2|[Bùi Huỳnh Kim Uyên](https://github.com/uyenbhku)|21521659|
|3|[Nguyễn Nguyên Giáp](https://github.com/Paignn)|21522025|
|4|[Nguyễn Bùi Thanh Mai](https://github.com/21522320)|21522320|
|5|[Đinh Tiến Đạt](https://github.com/GaChip)|19521330|

### THÔNG TIN CƠ BẢN
Đồ án đã sử dụng các công cụ/ngôn ngữ sau trong suốt quá trình thực hiện:
* Front-end: HTML, CSS và Javascript.
* Back-end: Javascript trên môi trường NodeJS.
* Cơ sở dữ liệu: SQL Server.

### CÁCH CHẠY PROJECT TRÊN LOCAL PC
Sau khi tải project từ github về máy tính cá nhân, ta cần thực hiện 1 số thao tác sau để có thể khởi chạy project:
* Đảm bảo máy đã cài đặt nodeJS và SQL Server.
* Bước 1: Trong Command prompt, sử dụng lệnh cd để tới folder của project.
* Bước 2: Trong Command prompt, sử dụng lệnh `npm i` để cài đặt các module cần thiết cho chương trình.
* Bước 3: Tạo database mới trong SQL Server, sau đó dùng các lệnh từ file `tables.sql` để tạo các table 
* Bước 4: Chạy `error_definition.sql` để định nghĩa các lỗi trong CSDL.
* Bước 5: Config cập nhật tự động bằng SQL Server Agent Jobs (chi tiết config có trong file `auto_update.sql`).
* Bước 6: Trong folder config, chỉnh sửa các thông tin của file `cnStr.js` đúng với thông tin của database đã được tạo(tên database, password,...).
* Bước 7: Phải start SQL Server Browser trên SQL Server 2022 Configuration Manager.
* Bước 8: Sau khi đã hoàn thành các bước trên, trong Command prompt, sử dụng lệnh `npm start` để server được khởi chạy, port đang sử dụng sẽ được thông báo, truy cập vào để xem kết quả.

<!-- ### VIDEO DEMO ĐỒ ÁN
[Link video demo](https://youtu.be/AUGFdoGetgI) -->

### MỘT SỐ CHỨC NĂNG CƠ BẢN CỦA ĐỒ ÁN (CURRENT STATUS)
* Quản lý sổ tiết kiệm theo phiếu.
* Đăng nhập tài khoản.
* Tạo phiếu gửi tiết kiệm với 3 loại tiết kiệm là: không kỳ hạn, kỳ hạn 3 tháng và kỳ hạn 6 tháng.
* Rút tiền với phiếu gửi tương ứng giữa kỳ, cuối kỳ.
* In phiếu rút và phiếu gửi.
* Cập nhật tiền lãi tự động (để demo thì nhóm đã scale theo phút), tự động tái tục cho đến khi tạo phiếu rút.
* Tra cứu phiếu gửi theo CMND/CCCD, ngày gửi, mã phiếu gửi.
* Lập báo cáo doanh số theo ngày.
* Theo dõi tình hình doanh số tháng hiện tại.
* Thay đổi quy định (thêm/khóa/mở loại tiết kiệm, sửa ngày rút tối thiểu, tiền gửi tối thiểu)


### CÁC DỰ ĐỊNH PHÁT TRIỂN TIẾP THEO (FUTURE PLAN)
* Chỉnh sửa giao diện cho thân thiện với người dùng hơn (hiển thị nhiều thông tin hơn) và tăng tính tiện lợi.
* Hoàn thiện tính năng thiết kế lãi bậc thang.
* Thêm tính năng in báo cáo.
* Hoàn thiện tính năng phân quyền.
* Thêm bộ lọc, tính năng sắp xếp kết quả tra cứu.
* Thêm tính năng sao kê dòng tiền phiếu gửi.
