FasdUAS 1.101.10   ��   ��    k             l     ��  ��      BringAppToFront.scpt     � 	 	 *   B r i n g A p p T o F r o n t . s c p t   
  
 l     ��  ��    C = Syntax:  osascript BringAppToFront.scpt "%application_path%"     �   z   S y n t a x :     o s a s c r i p t   B r i n g A p p T o F r o n t . s c p t   " % a p p l i c a t i o n _ p a t h % "      l     ��  ��    Q K Example:  osascript BringAppToFront.scpt "/Applications/Google Chrome.app"     �   �   E x a m p l e :     o s a s c r i p t   B r i n g A p p T o F r o n t . s c p t   " / A p p l i c a t i o n s / G o o g l e   C h r o m e . a p p "      l     ��������  ��  ��        l     ��  ��    I C This script will bring the indicated application to the foreground     �   �   T h i s   s c r i p t   w i l l   b r i n g   t h e   i n d i c a t e d   a p p l i c a t i o n   t o   t h e   f o r e g r o u n d      l     ��������  ��  ��        l     ��   ��     
!/bin/bash      � ! !  ! / b i n / b a s h   "�� " i      # $ # I     �� %��
�� .aevtoappnull  �   � **** % o      ���� 0 argv  ��   $ k     ? & &  ' ( ' r      ) * ) c      + , + l     -���� - n      . / . 4    �� 0
�� 
cobj 0 m    ����  / o     ���� 0 argv  ��  ��   , m    ��
�� 
TEXT * o      ���� 0 apppath   (  1 2 1 r   	  3 4 3 m   	 
��
�� boovtrue 4 o      ���� $0 processisrunning processIsRunning 2  5 6 5 O      7 8 7 r     9 : 9 6    ; < ; 2   ��
�� 
prcs < =    = > = 1    ��
�� 
bnid > m     ? ? � @ @ " c o m . m o o n s h i n e - i d e : o      ���� $0 runningprocesses runningProcesses 8 m     A A�                                                                                  sevs  alis    �  Macintosh HD               �(��H+  �>System Events.app                                              �$m���%        ����  	                CoreServices    �(��      ���    �>�=�<  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   6  B C B Z  ! / D E���� D =  ! % F G F o   ! "���� $0 runningprocesses runningProcesses G J   " $����   E r   ( + H I H m   ( )��
�� boovfals I o      ���� $0 processisrunning processIsRunning��  ��   C  J�� J Z   0 ? K L���� K =  0 3 M N M o   0 1���� $0 processisrunning processIsRunning N m   1 2��
�� boovfals L I  6 ;�� O��
�� .sysoexecTEXT���     TEXT O m   6 7 P P � Q Q 6 o p e n   - b   " c o m . m o o n s h i n e - i d e "��  ��  ��  ��  ��       �� R S��   R ��
�� .aevtoappnull  �   � **** S �� $���� T U��
�� .aevtoappnull  �   � ****�� 0 argv  ��   T ���� 0 argv   U �������� A�� V�� ?�� P��
�� 
cobj
�� 
TEXT�� 0 apppath  �� $0 processisrunning processIsRunning
�� 
prcs V  
�� 
bnid�� $0 runningprocesses runningProcesses
�� .sysoexecTEXT���     TEXT�� @��k/�&E�OeE�O� *�-�[�,\Z�81E�UO�jv  fE�Y hO�f  
�j Y hascr  ��ޭ