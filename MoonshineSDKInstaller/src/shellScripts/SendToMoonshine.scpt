FasdUAS 1.101.10   ��   ��    k             l     ��  ��      SendToMoonshine.scpt     � 	 	 *   S e n d T o M o o n s h i n e . s c p t   
  
 l     ��������  ��  ��        l     ��  ��    6 0 This script will notify any running instance of     �   `   T h i s   s c r i p t   w i l l   n o t i f y   a n y   r u n n i n g   i n s t a n c e   o f      l     ��  ��    9 3 Moonshine and MoonshineDevelopment with SDK update     �   f   M o o n s h i n e   a n d   M o o n s h i n e D e v e l o p m e n t   w i t h   S D K   u p d a t e      l     ��  ��      notification from MSDKI     �   0   n o t i f i c a t i o n   f r o m   M S D K I      l     ��������  ��  ��        l     ��   ��     
!/bin/bash      � ! !  ! / b i n / b a s h   "�� " i      # $ # I     �� %��
�� .aevtoappnull  �   � **** % o      ���� 0 argv  ��   $ k     r & &  ' ( ' r      ) * ) c      + , + l     -���� - n      . / . 4    �� 0
�� 
cobj 0 m    ����  / o     ���� 0 argv  ��  ��   , m    ��
�� 
TEXT * o      ���� 0 apppath   (  1 2 1 r   	  3 4 3 m   	 
��
�� boovtrue 4 o      ���� $0 processisrunning processIsRunning 2  5 6 5 O      7 8 7 r     9 : 9 6    ; < ; 2   ��
�� 
prcs < =    = > = 1    ��
�� 
bnid > m     ? ? � @ @ " c o m . m o o n s h i n e - i d e : o      ���� $0 runningprocesses runningProcesses 8 m     A A�                                                                                  sevs  alis    \  Macintosh HD                   BD ����System Events.app                                              ����            ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   6  B C B Z  ! / D E���� D =  ! % F G F o   ! "���� $0 runningprocesses runningProcesses G J   " $����   E r   ( + H I H m   ( )��
�� boovfals I o      ���� $0 processisrunning processIsRunning��  ��   C  J K J Z   0 ? L M���� L =  0 3 N O N o   0 1���� $0 processisrunning processIsRunning O m   1 2��
�� boovtrue M I  6 ;�� P��
�� .sysoexecTEXT���     TEXT P m   6 7 Q Q � R R 6 o p e n   - b   " c o m . m o o n s h i n e - i d e "��  ��  ��   K  S T S O   @ S U V U r   D R W X W 6  D P Y Z Y 2  D G��
�� 
prcs Z =  H O [ \ [ 1   I K��
�� 
bnid \ m   L N ] ] � ^ ^ : c o m . m o o n s h i n e - i d e . d e v e l o p m e n t X o      ���� $0 runningprocesses runningProcesses V m   @ A _ _�                                                                                  sevs  alis    \  Macintosh HD                   BD ����System Events.app                                              ����            ����  
 cu             CoreServices  0/:System:Library:CoreServices:System Events.app/  $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   T  ` a ` Z  T b b c���� b =  T X d e d o   T U���� $0 runningprocesses runningProcesses e J   U W����   c r   [ ^ f g f m   [ \��
�� boovfals g o      ���� $0 processisrunning processIsRunning��  ��   a  h�� h Z   c r i j���� i =  c f k l k o   c d���� $0 processisrunning processIsRunning l m   d e��
�� boovtrue j I  i n�� m��
�� .sysoexecTEXT���     TEXT m m   i j n n � o o N o p e n   - b   " c o m . m o o n s h i n e - i d e . d e v e l o p m e n t "��  ��  ��  ��  ��       �� p q��   p ��
�� .aevtoappnull  �   � **** q �� $���� r s��
�� .aevtoappnull  �   � ****�� 0 argv  ��   r ���� 0 argv   s �������� A�� t�� ?�� Q�� ] n
�� 
cobj
�� 
TEXT�� 0 apppath  �� $0 processisrunning processIsRunning
�� 
prcs t  
�� 
bnid�� $0 runningprocesses runningProcesses
�� .sysoexecTEXT���     TEXT�� s��k/�&E�OeE�O� *�-�[�,\Z�81E�UO�jv  fE�Y hO�e  
�j Y hO� *�-�[�,\Z�81E�UO�jv  fE�Y hO�e  
�j Y hascr  ��ޭ