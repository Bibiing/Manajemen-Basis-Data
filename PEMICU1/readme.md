## **1. School (Sekolah)**
Menyimpan data sekolah yang menerima pendaftaran siswa.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `school_id`  | CHAR(8) (Primary Key, Auto Increment)  | ID unik sekolah |
| `name`  | VARCHAR(255)  | Nama sekolah |
| `address`  | VARCHAR(255)  | Alamat lengkap sekolah |
| `phone_number`  | VARCHAR(16)  | Nomor telepon sekolah |
| `email`  | VARCHAR(255) (UNIQUE) | Email resmi sekolah |
| `capacity`  | INT  | Kapasitas maksimal siswa yang dapat diterima |

---

## **2. Student (Siswa)**
Menyimpan data siswa yang mendaftar ke sekolah.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `student_id`  | CHAR(8) (Primary Key, Auto Increment)  | ID unik siswa |
| `full_name`  | VARCHAR(255)  | Nama lengkap siswa |
| `date_of_birth`  | DATE  | Tanggal lahir siswa |
| `gender`  | ENUM('Male', 'Female')  | Jenis kelamin siswa. di model make CHAR(1) untuk 'F'/'M' | 
| `address`  | VARCHAR(255)  | Alamat lengkap siswa |
| `phone_number`  | VARCHAR(16)  | Nomor telepon siswa |
| `email`  | VARCHAR(255) (UNIQUE) | Email siswa |
| `previous_school`  | VARCHAR(255)  | Nama sekolah sebelumnya |

---

## **3. Parent (Orang Tua/Wali)**
Menyimpan data orang tua atau wali siswa.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `parent_id`  | CHAR(8) (Primary Key, Auto Increment)  | ID unik wali siswa |
| `student_id`  | CHAR(8) (Foreign Key ke Student)  | ID siswa terkait |
| `full_name`  | VARCHAR(255)  | Nama lengkap wali |
| `relationship`  | ENUM('Father', 'Mother', 'Guardian')  | Hubungan dengan siswa. dimodel makai varchar(255) | 
| `phone_number`  | VARCHAR(16)  | Nomor telepon wali |
| `occupation`  | VARCHAR(255)  | Pekerjaan wali |

---

## **4. Registration (Pendaftaran)**
Menyimpan data pendaftaran siswa ke sekolah tertentu.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `registration_id`  | CHAR(10) (Primary Key, Auto Increment)  | ID unik pendaftaran |
| `student_id`  | CHAR(8) (Foreign Key ke Student)  | ID siswa yang mendaftar |
| `school_id`  | CHAR(8) (Foreign Key ke School)  | ID sekolah tujuan |
| `registration_date`  | TIMESTAMP DEFAULT CURRENT_TIMESTAMP | Tanggal dan waktu pendaftaran |
| `registration_path`  | ENUM('Zoning', 'Affirmative', 'Achievement', 'Parent Transfer') | Jalur pendaftaran. di model makai varchar(255) | 
| `status`  | ENUM('Pending', 'Verified', 'Rejected') | Status pendaftaran. di model makai varchar(255) |

---

## **5. Documents (Dokumen Pendaftaran)**
Menyimpan dokumen yang diunggah siswa saat pendaftaran.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `document_id`  | CHAR(10) (Primary Key, Auto Increment)  | ID unik dokumen |
| `registration_id`  | CHAR(10) (Foreign Key ke Registration)  | ID pendaftaran terkait |
| `document_type`  | ENUM('Birth Certificate', 'Report Card', 'Family Card', 'Other') | Jenis dokumen. di model makai varchar(255) |
| `verification_status`  | ENUM('Pending', 'Verified', 'Rejected') | Status verifikasi dokumen. di model makai varchar(255) |

---

## **6. Selection (Seleksi)**
Menyimpan hasil seleksi siswa yang telah mendaftar.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `selection_id`  | CHAR(10) (Primary Key, Auto Increment)  | ID unik seleksi |
| `registration_id`  | CHAR(10) (Foreign Key ke Registration)  | ID pendaftaran terkait |
| `score`  | FLOAT (NULLABLE) | Skor seleksi (digunakan hanya untuk Jalur Prestasi) |
| `status`  | ENUM('Accepted', 'Rejected', 'Waitlisted') | Status hasil seleksi. di model makai varchar(255) |

---

## **7. Re-registration (Daftar Ulang)**
Menyimpan data siswa yang berhasil diterima dan melakukan daftar ulang.  

| **Nama Atribut**  | **Tipe Data**  | **Deskripsi**  |
|------------------|--------------|---------------|
| `re_registration_id`  | CHAR(10) (Primary Key, Auto Increment)  | ID unik daftar ulang |
| `selection_id`  | CHAR(10) (Foreign Key ke Selection)  | ID seleksi terkait |
| `status`  | ENUM('Completed', 'Pending', 'Cancelled') | Status daftar ulang. di model makai varchar(255) |
| `re_registration_date`  | TIMESTAMP DEFAULT CURRENT_TIMESTAMP | Tanggal daftar ulang |

---

## **Final Relationships (Hubungan Antar Entitas)**
- **Student ↔ Parent** → **One-to-Many** (Satu siswa bisa memiliki lebih dari satu wali)  
- **Student ↔ Registration** → **One-to-One** (Setiap siswa hanya bisa mendaftar satu kali per sekolah)  
- **Registration ↔ School** → **Many-to-One** (Banyak pendaftaran bisa menuju satu sekolah)  
- **Registration ↔ Documents** → **One-to-Many** (Satu pendaftaran bisa memiliki banyak dokumen)  
- **Registration ↔ Selection** → **One-to-One** (Setiap pendaftaran hanya memiliki satu hasil seleksi)  
- **Selection ↔ Re-registration** → **One-to-One** (Siswa yang diterima hanya bisa daftar ulang satu kali)   

## CDM
![CDM](https://drive.google.com/uc?export=view&id=1ACRk4QMzbVevkObAjTUADUP-ygZWcGeV)
import to your oracle data model [cdm](dl_settings.xml) - remove file_path attribute from dokumen



