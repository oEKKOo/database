
/*1、在teacher表中定义Tno为主键。*/

ALTER TABLE teacher
ADD PRIMARY KEY (Tno);

/*3、在sc表中定义Sno和Cno联合构成主键。*/
ALTER TABLE sc
ADD PRIMARY KEY (Sno, Cno);

/*4、在tc表中定义Tno和Cno联合构成主键。*/
ALTER TABLE tc
ADD PRIMARY KEY (Tno, Cno);

/*5、定义course表中的credit列默认值为0。*/
ALTER TABLE course
MODIFY credit FLOAT(255, 1) NOT NULL DEFAULT 0;

/*6、定义teacher表中的gender列的CHECK约束“男”或“女”。*/
ALTER TABLE teacher
ADD CONSTRAINT chk_gender CHECK (gender IN ('男', '女'));

/*7、定义course表中的Cno列为自增。*/
ALTER TABLE course
MODIFY Cno INT NOT NULL AUTO_INCREMENT;

/*7、在student表与sc表之间定义外键Sno。*/
ALTER TABLE sc
ADD CONSTRAINT fk_sc_student FOREIGN KEY (Sno) REFERENCES student(Sno);

/*8、在course表与sc表之间定义外键Cno。*/
ALTER TABLE sc
ADD CONSTRAINT fk_sc_course FOREIGN KEY (Cno) REFERENCES course(Cno);

/*9、在teacher表与tc表之间定义外键Tno。*/
ALTER TABLE tc
ADD CONSTRAINT fk_tc_teacher FOREIGN KEY (Tno) REFERENCES teacher(Tno);

/*10、在course表与tc表之间定义外键Cno。*/
ALTER TABLE tc
ADD CONSTRAINT fk_tc_course FOREIGN KEY (Cno) REFERENCES course(Cno);
