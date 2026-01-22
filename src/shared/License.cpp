#include "License.h"
#include "WinlicenseSDK.h"

using namespace std;

#define sprintf sprintf_s

int license()
{
	int Status;
	char AuxBuffer[255];
	char RegName[255];
	char CompanyName[255];
	char CustomData[255];
	char hid[255];
	SYSTEMTIME TrialDate = { 0,0,0,0,0,0,0,0 };
	int RegExtendedInfo;

	WLHardwareGetID(hid);
	printf("WLHardwareGetID:%s\n", hid);
	//TODO 将这个ID写到“请将此文件发给QQ：29173289购买.txt”
	// 以写模式打开文件
	ofstream outfile;
	outfile.open("请将此文件发给QQ：29173289获得注册码.txt");
	// 向文件写入用户输入的数据
	outfile << hid << endl;
	// 关闭打开的文件
	outfile.close();

	Status = WLRegGetStatus(&RegExtendedInfo);

	switch (Status)
	{
	case 0:
		std::cout << "Trial\n";
		break;

	case 1:
		std::cout << "授权成功\n";
		break;

	case 2:
		std::cout << "Invalid License\n";
		break;

	case 3:
		std::cout << "License Locked to different machine\n";
		break;

	case 4:
		std::cout << "No more HW-ID changes allowed\n";
		break;

	case 5:
		std::cout << "License Key expired\n";
		break;
	}
	//printf("W1234\n");

	//std::cout << Status;

	if (Status != 1)
	{
		//*
		// set trial labels data                
		sprintf(AuxBuffer, "%d", WLTrialDaysLeft());
		printf("试用剩余天数:%s\n", AuxBuffer);
		sprintf(AuxBuffer, "%d", WLTrialExecutionsLeft());
		printf("试用剩余执行次数WLTrialExecutionsLeft:%s\n", AuxBuffer);
		sprintf(AuxBuffer, "%d", WLTrialGlobalTimeLeft());
		printf("试用全局剩余次数WLTrialGlobalTimeLeft:%s\n", AuxBuffer);
		sprintf(AuxBuffer, "%d", WLTrialRuntimeLeft());
		printf("试用剩余运行次数:%s\n", AuxBuffer);
		WLTrialExpirationDate(&TrialDate);
		printf("试用到期日期WLTrialExpirationDate:%d-%d-%d\n", TrialDate.wYear, TrialDate.wMonth, TrialDate.wDay);
		//*/

	}
	else
	{
		std::cout << "授权给：\n";
		///*
		WLRegGetLicenseInfo(RegName, CompanyName, CustomData);
		printf("%s-%s\n%s\n", RegName, CompanyName, CustomData);
		sprintf(AuxBuffer, "%d", WLRegDaysLeft());
		printf("剩余时间:%s\n", AuxBuffer);
		sprintf(AuxBuffer, "%d", WLRegExecutionsLeft());
		printf("剩余次数:%s\n", AuxBuffer);
		WLRegExpirationDate(&TrialDate);
		printf("到期日期e:%d-%d-%d\n", TrialDate.wYear, TrialDate.wMonth, TrialDate.wDay);
		//*/
	}
	return 0;
	//std::cout << "Hello World!\n";
	//system("pause");
}
