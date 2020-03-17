#include<iostream>
#include<time.h>
#include<list>
#include<stdlib.h>
#include<vector>
#include<algorithm>
#include<map>
#include<unordered_map>
#include<set>
#include<string>
#include<chrono>
#include<ctime>

using namespace std;

enum class PaiXinHuxi
{
	x_qing,         //起手 4张
	x_xiao,         //起手 3张
	x_yiersan,
	x_erqishi,
	d_qing,
	d_xiao,
	d_yiersan,      //123
	d_erqishi,       //2710
	d_peng
};

static const unordered_map<PaiXinHuxi, int> paixingHuxi
{
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::x_qing,9),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::x_xiao   ,3),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::x_yiersan,3),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::x_erqishi,3),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::d_qing   ,12),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::d_xiao   ,6),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::d_yiersan,6),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::d_erqishi,6),
	std::pair<PaiXinHuxi,int>(PaiXinHuxi::d_erqishi,3)
};
static const vector<int> publicPailib
{
	101,102,103,104,105,106,107,108,109,110,
	101,102,103,104,105,106,107,108,109,110,
	101,102,103,104,105,106,107,108,109,110,
	101,102,103,104,105,106,107,108,109,110,
	201,202,203,204,205,206,207,208,209,210,
	201,202,203,204,205,206,207,208,209,210,
	201,202,203,204,205,206,207,208,209,210,
	201,202,203,204,205,206,207,208,209,210
};

static const vector<int> AllPaiValue
{
	101,102,103,104,105,106,107,108,109,110,
	201,202,203,204,205,206,207,208,209,210
};
// 101 101 102 102 103 103 104 104 105 105 106 106 107 107 108 108 109 109 110 110
// 101 102 103 101 102 103 104 105 106 104 105 106 107 108 109 107 108 109 110 110


int getTingPai(vector<int> handPokers, map<int, int>& res_ting_hu, const int& huxi);
void markDnfTingCard(const vector<int>& markTempl, vector<int> tempHandPoker, map<int, int>& res_ting_hu, const int& kindNum, const int&tempHuxi);
int getPaiType(const int& paiNum);
int getPaiValue(const int& paiNum);

static const int kindpai = 555;              //王赖牌

int getCountAndDelByhand(vector<int>& handpokers, const int& paiVal)
{
	int res = 0;

	int left = 0;
	int right = (int)handpokers.size() - 1;

	while (left <= right)
	{
		if (handpokers[right--] != paiVal)break;
		handpokers.pop_back();
		res++;
	}

	return res;
}

void Setres_ting_hu(map<int, int>& ting_hu, const int& ting, const int& huxi)
{
	if (huxi > ting_hu[ting])
	{
		ting_hu[ting] = huxi;
	}
}

vector<vector<int>> getValidComByHandpokers(const vector<int>& handpokers)
{
	unordered_map<int, int> pai_count;
	vector<vector<int>> retComs;
	for (auto& paiValue : handpokers)
	{
		pai_count[paiValue]++;
	}
	int prePaivalue = 0;
	for (auto& paiValue : handpokers)
	{
		if (prePaivalue == paiValue) continue;
		prePaivalue = paiValue;
		if (getPaiValue(paiValue) == 2)      //二七十
		{
			if (pai_count[paiValue] == 2 && pai_count[paiValue + 5] == 2 && pai_count[paiValue + 8] == 2)
			{
				retComs.emplace_back(vector<int>{ paiValue, paiValue + 5, paiValue + 8});
			}

			if (pai_count[paiValue + 5] >= 1 && pai_count[paiValue + 8] >= 1)
			{
				retComs.emplace_back(vector<int>{ paiValue, paiValue + 5, paiValue + 8});
			}
		}

		//顺子
		if (pai_count[paiValue] == 2)
		{
			int type = getPaiType(paiValue);         //壹壹一
			if (type == 1)
			{
				if (pai_count[paiValue + 100] > 0)
					retComs.emplace_back(vector<int>{ paiValue, paiValue, paiValue + 100});
			}
			else
			{
				if (pai_count[paiValue - 100] > 0)
					retComs.emplace_back(vector<int>{ paiValue, paiValue, paiValue - 100});
			}

			if (pai_count[paiValue + 1] == 2 && pai_count[paiValue + 2] == 2)
			{
				retComs.emplace_back(vector<int>{ paiValue, paiValue + 1, paiValue + 2});
			}
		}

		if (pai_count[paiValue + 1] >= 1 && pai_count[paiValue + 2] >= 1)
		{
			retComs.emplace_back(vector<int>{ paiValue, paiValue + 1, paiValue + 2});
		}
	}
	return retComs;
}

int combination2(const unordered_map<int, int>& pai_Count,const vector<vector<int>>& pSum, size_t nCombiLen, vector<vector<vector<int>>>& res)
{
	size_t nSumLen = pSum.size();
	nCombiLen = nCombiLen > nSumLen ? nSumLen : nCombiLen;
	vector<int> nSumIndex(nCombiLen + 1, 0);
	vector<vector<int>> nSumCount(nCombiLen);
	for (int i = 0; i < nCombiLen + 1; i++)  // 0 1 2 3 4 ...nCombiLen
	{										 //-1 0 1 2 3 ...nCombiLen - 1
		nSumIndex[i] = i - 1;
	}

	bool flag = true;
	size_t nPos = nCombiLen;
	while (nSumIndex[0] == -1)
	{
		if (flag)
		{
			unordered_map<int, int> key_value;
			bool isVaild = true;
			for (int i = 1; i < nCombiLen + 1; i++)
			{
				nSumCount[i - 1] = pSum[nSumIndex[i]];
				for (const auto& it : pSum[nSumIndex[i]])
				{
					key_value[it]++;
					if (key_value[it] > pai_Count.at(it))
					{
						isVaild = false;
						break;
					}
				}

				if (isVaild == false)
					break;
			}

			if (isVaild)
			{
				res.emplace_back(nSumCount);
			}

			flag = false;
		}

		nSumIndex[nPos]++;
		if (nSumIndex[nPos] == nSumLen)
		{
			nSumIndex[nPos] = 0;
			nPos--;
			continue;
		}

		if (nPos < nCombiLen)
		{
			++nPos;
			nSumIndex[nPos] = nSumIndex[nPos - 1];
			continue;
		}

		if (nPos == nCombiLen)
		{
			flag = true;
		}
	}
	return 0;
}

vector<vector<int>> combination3(const vector<int>& pSum, size_t nCombiLen)
{
	size_t nSumLen = pSum.size();
	nCombiLen = nCombiLen > nSumLen ? nSumLen : nCombiLen;
	vector<int> nSumIndex(nCombiLen + 1, 0);
	vector<int> nSumCount(nCombiLen);
	vector<vector<int>> res;
	for (int i = 0; i < nCombiLen + 1; i++)  // 0 1 2 3 4 ...nCombiLen
	{										 //-1 0 1 2 3 ...nCombiLen - 1
		nSumIndex[i] = i - 1;
	}

	bool flag = true;
	size_t nPos = nCombiLen;
	while (nSumIndex[0] == -1)
	{
		if (flag)
		{
	
			for (int i = 1; i < nCombiLen + 1; i++)
			{
				nSumCount[i - 1] = pSum[nSumIndex[i]];
			}
			res.emplace_back(nSumCount);
			flag = false;
		}

		nSumIndex[nPos]++;
		if (nSumIndex[nPos] == nSumLen)
		{
			nSumIndex[nPos] = 0;
			nPos--;
			//flag = true;
			continue;
		}

		if (nPos < nCombiLen)
		{
			++nPos;
			nSumIndex[nPos] = nSumIndex[nPos - 1];
			//flag = true;
			continue;
		}

		if (nPos == nCombiLen)
		{
			flag = true;
		}
	}
	return res;
}

int getPaiType(const int& paiNum)
{
	return paiNum / 100;
}

int getPaiValue(const int& paiNum)
{
	return paiNum % 100;
}

vector<int> getRandziPai(const int& num)     //发牌
{
	vector<int> paiLib(publicPailib);
	random_shuffle(paiLib.begin(), paiLib.end());
	vector<int> res;
	int randIndex = 0;
	size_t size = paiLib.size() - 1;
	for (int i = 0; i < num; i++)
	{
		randIndex = rand() % size;
		res.emplace_back(paiLib[randIndex]);
		swap(paiLib[randIndex], paiLib[size]);
		--size;
	}

	return res;
}

void printfvector(const vector<int> &handPokers)
{
	cout << "{";

	for (int i = 0; i < handPokers.size(); i++)
	{
		cout << handPokers[i] << ", ";
		if (i != 0 && i % 10 == 0)
			cout << endl;
	}

	cout << "}" << endl;
}

vector<vector<int>> resolvexiaoQingPai(vector<int>& handpokers)
{
	vector<vector<int>> res;
	int paiCount = 0;
	int tempVal = 0;
	int left = 0;
	size_t right = handpokers.size() - 1;
	int delStartIndex = 0;
	int tmpPaicount = 0;
	while (left <= right)
	{
		if (handpokers[left] != tempVal || paiCount == 4)
		{
			if (paiCount >= 3)
			{
				res.emplace_back(vector<int>());
				delStartIndex = left - paiCount;
				left -= paiCount;
				tmpPaicount = paiCount;
				for (; paiCount > 0; paiCount--)
				{
					res.back().emplace_back(handpokers[delStartIndex]);
					handpokers.erase(begin(handpokers) + delStartIndex);
					right--;
				}
			}
			tempVal = handpokers[left];
			paiCount = 1;
		}
		else
		{
			++paiCount;
		}
		++left;
	}

	if (paiCount >= 3)
	{
		res.emplace_back(vector<int>());
		while (paiCount--)
		{
			res.back().emplace_back(handpokers.back());
			handpokers.pop_back();
		}
	}

	return res;
}

int getxiaoQingHuxi(vector<vector<int>>& xiaoQingPai)
{
	int res = 0;
	int type = 0;
	size_t size = 0;
	for (int i = 0; i < xiaoQingPai.size(); i++)
	{
		type = getPaiType(xiaoQingPai[i][0]);
		size = xiaoQingPai[i].size();
		if (type == 1)  //小
		{
			if (size == 4)
			{
				res += paixingHuxi.at(PaiXinHuxi::x_qing);
			}
			else
			{
				res += paixingHuxi.at(PaiXinHuxi::x_xiao);
			}
		}
		else            //大
		{
			if (size == 4)
			{
				res += paixingHuxi.at(PaiXinHuxi::d_qing);
			}
			else
			{
				res += paixingHuxi.at(PaiXinHuxi::d_xiao);
			}
		}
	}
	return res;
}

bool isVaildCombi(const vector<int>& combi)
{
	vector<int> type(3, 0);
	vector<int> value(3, 0);

	for (int i = 0; i < combi.size(); i++)
	{
		type[i] = getPaiType(combi[i]);
		value[i] = getPaiValue(combi[i]);
	}

	if (combi[0] - combi[1] == -1 && combi[1] - combi[2] == -1)
	{
		return true;
	}
	else if (value[0] == value[1] && value[1] == value[2])
	{
		return true;
	}
	else if (value[0] == 2 && value[1] == 7 && value[2] == 10 && type[0] == type[1] && type[1] == type[2])
	{
		return true;
	}

	return false;
}

vector<int> getMenzi(const vector<vector<int>>& combis,const vector<int>& handpokers)
{
	unordered_map<int, vector<int>> pai_Index;
	for (int i = 0; i < handpokers.size(); i++)
	{
		pai_Index[handpokers[i]].push_back(i);
	}


	for (const auto& com : combis)
	{
		for (const auto& pai : com)
		{
			pai_Index[pai].pop_back();
		}
	}
	vector<int> res;
	for (const auto& it : pai_Index)
	{
		if (!it.second.empty())
		{
			for (const auto& index : it.second)
			{
				res.emplace_back(handpokers[index]);
			}
		}
	}

	return res;
}


vector<vector<vector<int>>> getAllCardCombi(const vector<int>& handpokers, const int &kindNum)
{
	// 102 102 104 104 106 107 110 201 202 202 204 207 555
	int comsize = static_cast<int>(handpokers.size() + kindNum) / 3 - 1 ;
	int tempNum = 1;
	if ((handpokers.size() + kindNum) % 3 == 2)
	{
		tempNum = 0;
		++comsize;
	}

	comsize -= kindNum;

	vector<vector<vector<int>>> res;
	vector<vector<int>> vaildcombis;
	vector<vector<int>> paiIndexList;
	auto end = std::chrono::system_clock::now();

	vaildcombis = getValidComByHandpokers(handpokers);
	cout << vaildcombis.size() << endl;
	for (const auto& com : vaildcombis)
	{
		for (const auto& pai : com)
		{
			cout << pai << " ";
		}
		cout << endl;
	}

	int tempComSize = comsize + kindNum + tempNum;

	unordered_map<int, int> pai_Count;

	for (const auto& pai : handpokers)
	{
		pai_Count[pai]++;
	}

	for (int i = tempComSize; i >= comsize; i--)
	{
		if (i > 0 && vaildcombis.size() >= i)
		{
			combination2(pai_Count,vaildcombis, i, tempcombss);
		}
		//if (tempcombss.size() > 0) break;
	}

	for (int i = 0; i < tempcombss.size(); i++)
	{
		vector<int> tempMenzi = getMenzi(tempcombss[i], handpokers);
		tempcombss[i].emplace_back(tempMenzi);
		res.emplace_back(tempcombss[i]);
	}
	if ((kindNum * 2) + 2 >= handpokers.size())
	{
		vector<vector<int>> tempHandPokers(1, handpokers);
		res.emplace_back(tempHandPokers);
	}
	return res;
}

int GetvalidCombiHufen(const vector<vector<int>>& combi)
{
	int res = 0;
	vector<int> types(3, 0);
	vector<int> values(3, 0);
	for (int i = 0; i < combi.size() - 1; i++)              //最后一组不是有效组合
	{
		for (int LOOP = 0; LOOP < combi[i].size(); LOOP++)
		{
			types[LOOP] = getPaiType(combi[i][LOOP]);
			values[LOOP] = getPaiValue(combi[i][LOOP]);
		}

		if (types[0] == types[1] && types[1] == types[2])
		{
			if (values[0] == 1)  //123
			{
				if (types[0] == 1)
				{
					res += paixingHuxi.at(PaiXinHuxi::x_yiersan);
				}
				else
				{
					res += paixingHuxi.at(PaiXinHuxi::d_yiersan);
				}
			}
			else if (values[0] == 2 && values[1] == 7) //2 7 10
			{
				if (types[0] == 1)
				{
					res += paixingHuxi.at(PaiXinHuxi::x_erqishi);
				}
				else
				{
					res += paixingHuxi.at(PaiXinHuxi::d_erqishi);
				}
			}
		}
	}
	return res;
}

void setChuTingCard(const vector<int>& combi, map<int, int> &resChu_ting,
	const vector<int>& value, const vector<int>& type,
	const int& firstIndex, const int& scondIndex, const int& pubicHuxi)
{
	if (combi[firstIndex] - combi[scondIndex] == -1)
	{

		if (value[firstIndex] != 1)
		{
			if (value[firstIndex] - 1 == 1)                     //听的是1
			{
				if (type[firstIndex] == 1)
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] - 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan));
					//resChu_ting[combi[firstIndex] - 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan);
				}
				else
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] - 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan));
					//resChu_ting[combi[firstIndex] - 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan);
				}
			}
			else
			{
				Setres_ting_hu(resChu_ting, combi[firstIndex] - 1, pubicHuxi);
				//resChu_ting[combi[firstIndex] - 1] = pubicHuxi;
			}
		}

		if (value[scondIndex] != 10)
		{
			if (value[scondIndex] + 1 == 3)                     //听的是3
			{
				if (type[scondIndex] == 1)
				{
					Setres_ting_hu(resChu_ting, combi[scondIndex] + 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan));
					//resChu_ting[combi[scondIndex] + 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan);
				}
				else
				{
					Setres_ting_hu(resChu_ting, combi[scondIndex] + 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan));
					//resChu_ting[combi[scondIndex] + 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan);
				}
			}
			else
			{
				Setres_ting_hu(resChu_ting, combi[scondIndex] + 1, pubicHuxi);
				//resChu_ting[combi[scondIndex] + 1] = pubicHuxi;
			}
		}

	}
	else if (combi[firstIndex] - combi[scondIndex] == -2)
	{
		if (value[firstIndex] + 1 == 2)                     //听的是2
		{
			if (type[firstIndex] == 1)
			{
				Setres_ting_hu(resChu_ting, combi[firstIndex] + 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan));
				//resChu_ting[combi[firstIndex] + 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_yiersan);
			}
			else
			{
				Setres_ting_hu(resChu_ting, combi[firstIndex] + 1, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan));
				//resChu_ting[combi[firstIndex] + 1] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_yiersan);
			}
		}
		else
		{
			Setres_ting_hu(resChu_ting, combi[firstIndex] + 1, pubicHuxi);
			//resChu_ting[combi[firstIndex] + 1] = pubicHuxi;
		}
	}
	else if (value[firstIndex] == value[scondIndex])
	{
		Setres_ting_hu(resChu_ting, value[firstIndex] + 100, pubicHuxi);
		Setres_ting_hu(resChu_ting, value[firstIndex] + 200, pubicHuxi);
		//resChu_ting[value[firstIndex] + 100] = pubicHuxi;
		//resChu_ting[value[firstIndex] + 200] = pubicHuxi;

		if (type[firstIndex] == type[scondIndex] && type[scondIndex] == 1)
			Setres_ting_hu(resChu_ting, value[firstIndex] + 100, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_xiao));
			//resChu_ting[value[firstIndex] + 100] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_xiao);      //有可能会笑 

		if (type[firstIndex] == type[scondIndex] && type[scondIndex] == 2)
			Setres_ting_hu(resChu_ting, value[firstIndex] + 200, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_xiao));
			//resChu_ting[value[firstIndex] + 200] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_xiao);      //有可能会笑 
	}
	else
	{
		if (type[firstIndex] == type[scondIndex])
		{
			if (value[firstIndex] == 2 && value[scondIndex] == 7)
			{
				if (type[firstIndex] == 1)
				{
					Setres_ting_hu(resChu_ting, combi[scondIndex] + 3, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi));
					//resChu_ting[combi[scondIndex] + 3] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi);
				}
				else
				{
					Setres_ting_hu(resChu_ting, combi[scondIndex] + 3, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi));
					//resChu_ting[combi[scondIndex] + 3] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi);
				}
			}
			else if (value[firstIndex] == 2 && value[scondIndex] == 10)
			{
				if (type[firstIndex] == 1)
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] + 5, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi));
					//resChu_ting[combi[firstIndex] + 5] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi);
				}
				else
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] + 5, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi));
					//resChu_ting[combi[firstIndex] + 5] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi);
				}
			}
			else if (value[firstIndex] == 7 && value[scondIndex] == 10)
			{
				if (type[firstIndex] == 1)
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] - 5, pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi));
					//resChu_ting[combi[firstIndex] - 5] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::x_erqishi);
				}
				else
				{
					Setres_ting_hu(resChu_ting, combi[firstIndex] - 5, pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi));
					//resChu_ting[combi[firstIndex] - 5] = pubicHuxi + paixingHuxi.at(PaiXinHuxi::d_erqishi);
				}
			}
		}
	}
}

void getchuTingPairByTwo(vector<int> combi, map<int, int> &resChu_ting, const int& pubicHuxi)    //combi传人 3张牌   获取打出哪张 听什么牌
{
	//下标0 为打出牌  后面为听的牌
	size_t comSize = combi.size();
	vector<int> type(comSize, 0);
	vector<int> value(comSize, 0);
	sort(combi.begin(), combi.end());

	for (int i = 0; i < comSize; i++)
	{
		type[i] = getPaiType(combi[i]);
		value[i] = getPaiValue(combi[i]);
	}

	setChuTingCard(combi, resChu_ting, value, type, 0, 1, pubicHuxi);
}


void getchuTingPairByFour(vector<int> combi, map<int, int> &resChu_ting, const int& pubicHuxi)    //combi传人 3张牌   获取打出哪张 听什么牌
{
	size_t comSize = combi.size();
	vector<int> type(comSize, 0);
	vector<int> value(comSize, 0);
	sort(combi.begin(), combi.end());

	for (int i = 0; i < comSize; i++)
	{
		type[i] = getPaiType(combi[i]);
		value[i] = getPaiValue(combi[i]);
	}
	if (type[0] == type[1] && value[0] == value[1])
	    setChuTingCard(combi, resChu_ting, value, type, 2, 3, pubicHuxi);

	if (type[2] == type[3] && value[2] == value[3])
		setChuTingCard(combi, resChu_ting, value, type, 0, 1, pubicHuxi);


	const static vector<vector<int>> indexValue   //三张组合 打出一张单挑情况
	{
		{0,1,2,3},
		{0,1,3,2},
		{0,2,3,1},
		{1,2,3,0}
	};

	int firstIndex;
	for (int i = 0; i < indexValue.size(); i++)
	{
		if (isVaildCombi({ combi[indexValue[i][0]],combi[indexValue[i][1]], combi[indexValue[i][2]] }))
		{
			
			//既然剩2张 则是打出一张听另一张嘛
			int tempHufen = 0;
			if (value[indexValue[i][0]] == 1)
			{
				if (value[indexValue[i][0]] == 1)
				{
					tempHufen = paixingHuxi.at(PaiXinHuxi::x_yiersan);
				}
				else
				{
					tempHufen = paixingHuxi.at(PaiXinHuxi::d_yiersan);
				}
			}
			else if (value[indexValue[i][0]] == 2)
			{
				if (value[indexValue[i][0]] == 1)
				{
					tempHufen = paixingHuxi.at(PaiXinHuxi::x_erqishi);
				}
				else
				{
					tempHufen = paixingHuxi.at(PaiXinHuxi::d_erqishi);
				}
			}
			firstIndex = indexValue[i][3];
			Setres_ting_hu(resChu_ting, combi[firstIndex], pubicHuxi + tempHufen);
			resChu_ting[combi[firstIndex]] = pubicHuxi + tempHufen;
		}
	}
}

vector<int> getmarkTempl(const vector<int>& handPokers)
{
	unordered_map<int, int> markTempl;
	unordered_map<int, int> pai_count;

	if (handPokers.size() == 1)
	{
		markTempl[handPokers[0]] = 1;
	}
	for (int i = 0; i < handPokers.size(); i++)
	{
		pai_count[handPokers[i]] = pai_count[handPokers[i]] + 1;
	}

	int value = 0;
	int type = 0;
	int count = 0;
	for (int i = 0; i < handPokers.size(); i++)
	{
		type = getPaiType(handPokers[i]);
		value = getPaiValue(handPokers[i]);
		count = pai_count[handPokers[i]];
		if (count == 2)											   // 101 101 101              
		{
			markTempl[handPokers[i]] = 1;
			continue;
		}

		if (type == 1 && pai_count[handPokers[i] + 100] == 1)      // 101 201 101 
		{
			markTempl[handPokers[i] + 100] = 1;
		}
		else if (type == 2 && pai_count[handPokers[i] - 100] == 1) // 101 201 201
		{
			markTempl[handPokers[i] - 100] = 1;
		}

		if (value == 1)
		{
			if (pai_count[type * 100 + 2] == 1 && pai_count[type * 100 + 3] == 0) //101 102 103
			{
				markTempl[type * 100 + 3] = 1;
			}
			else if (pai_count[type * 100 + 3] == 1 && pai_count[type * 100 + 2] == 0) //101 103 102
			{
				markTempl[type * 100 + 2] = 1;
			}
		}
		else if (value == 2)
		{
			if (pai_count[type * 100 + 7] == 1 && pai_count[type * 100 + 10] == 0)
			{
				markTempl[type * 100 + 10] = 1;
			}
			else if (pai_count[type * 100 + 10] == 1 && pai_count[type * 100 + 7] == 0)
			{
				markTempl[type * 100 + 7] = 1;
			}
			else if (pai_count[type * 100 + 1] == 1 && pai_count[type * 100 + 3] == 0)
			{
				markTempl[type * 100 + 3] = 1;
			}
			else if (pai_count[type * 100 + 3] == 1 && pai_count[type * 100 + 1] == 0)
			{
				markTempl[type * 100 + 1] = 1;
			}
			else if (pai_count[type * 100 + 3] == 1 && pai_count[type * 100 + 4] == 0)
			{
				markTempl[type * 100 + 4] = 1;
			}
			else if (pai_count[type * 100 + 4] == 1 && pai_count[type * 100 + 3] == 0)
			{
				markTempl[type * 100 + 3] = 1;
			}
		}
		else if (value == 7)
		{
			if (pai_count[type * 100 + 2] == 1 && pai_count[type * 100 + 10] == 0)
			{
				markTempl[type * 100 + 10] = 1;
			}
			else if (pai_count[type * 100 + 10] == 1 && pai_count[type * 100 + 2] == 0)
			{
				markTempl[type * 100 + 2] = 1;
			}
			else if (pai_count[type * 100 + 5] == 1 && pai_count[type * 100 + 6] == 0)
			{
				markTempl[type * 100 + 6] = 1;
			}
			else if (pai_count[type * 100 + 6] == 1 && pai_count[type * 100 + 5] == 0)
			{
				markTempl[type * 100 + 5] = 1;
			}
			else if (pai_count[type * 100 + 8] == 1 && pai_count[type * 100 + 9] == 0)
			{
				markTempl[type * 100 + 9] = 1;
			}
			else if (pai_count[type * 100 + 9] == 1 && pai_count[type * 100 + 8] == 0)
			{
				markTempl[type * 100 + 8] = 1;
			}
		}
		else if (value == 9)
		{
			if (pai_count[handPokers[i] - 2] == 1 && pai_count[handPokers[i] - 1] == 0)
			{
				markTempl[handPokers[i] - 1] = 1;
			}
			else if (pai_count[handPokers[i] - 1] == 1 && pai_count[handPokers[i] - 2] == 0)
			{
				markTempl[handPokers[i] - 2] = 1;
			}
			else if (pai_count[handPokers[i] + 2] == 1 && pai_count[handPokers[i] + 1] == 0)
			{
				markTempl[handPokers[i] + 1] = 1;
			}
		}
		else if (value == 10)
		{
			if (pai_count[type * 100 + 2] == 1 && pai_count[type * 100 + 7] == 0)
			{
				markTempl[type * 100 + 7] = 1;
			}
			else if (pai_count[type * 100 + 7] == 1 && pai_count[type * 100 + 2] == 0)
			{
				markTempl[type * 100 + 2] = 1;
			}
			else if (pai_count[type * 100 + 8] == 1 && pai_count[type * 100 + 9] == 0)
			{
				markTempl[type * 100 + 9] = 1;
			}
			else if (pai_count[type * 100 + 9] == 1 && pai_count[type * 100 + 8] == 0)
			{
				markTempl[type * 100 + 8] = 1;
			}
		}
		else
		{
			if (pai_count[handPokers[i] - 2] == 1 && pai_count[handPokers[i] - 1] == 0)
			{
				markTempl[handPokers[i] - 1] = 1;
			}
			else if (pai_count[handPokers[i] - 1] == 1 && pai_count[handPokers[i] - 2] == 0)
			{
				markTempl[handPokers[i] - 2] = 1;
			}
			else if (pai_count[handPokers[i] + 2] == 1 && pai_count[handPokers[i] + 1] == 0)
			{
				markTempl[handPokers[i] + 1] = 1;
			}
			else if (pai_count[handPokers[i] + 1] == 1 && pai_count[handPokers[i] + 2] == 0)
			{
				markTempl[handPokers[i] + 2] = 1;
			}
		}
	}


	vector<int> possibilityHus;

	for (const auto& it2 : markTempl)
	{
		possibilityHus.emplace_back(it2.first);
	}
	return possibilityHus;
}

void DOneKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	for (auto& paiValue : AllPaiValue)
	{
		Setres_ting_hu(res_ting_hu, paiValue, tempHuxi);
	}
}

void DTwoKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	//王 王  一 一 一 二 三 四   五 六  王是3个，到这里手牌数肯定是模除3余2
	map<int, int> tempChuTing;
	vector<int> type(2, 0);
	vector<int> value(2, 0);
	for (int i = 0; i < handpokers.size(); i++)
	{
		type[i] = getPaiType(handpokers[i]);
		value[i] = getPaiValue(handpokers[i]);
	}
	setChuTingCard(handpokers, tempChuTing, value, type, 0, 1, 0);
	if (tempChuTing.size() != 0)
	{
		//一个赖子可以解决一对
		for (auto& paiValue : AllPaiValue)
		{
			Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempChuTing[paiValue]);
		}
	}
	else
	{
		vector<int> temComs1(2, handpokers[0]);
		vector<int> temComs2(2, handpokers[1]);
		vector<int> type1(2, getPaiType(handpokers[0]));
		vector<int> value1(2, getPaiValue(handpokers[0]));
		vector<int> type2(2, getPaiType(handpokers[1]));
		vector<int> value2(2, getPaiValue(handpokers[1]));
		setChuTingCard(temComs1, res_ting_hu, value1, type1, 0, 1, tempHuxi);
		setChuTingCard(temComs2, res_ting_hu, value2, type2, 0, 1, tempHuxi);
	}
}

void DThreeKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu,const int & tempHuxi)
{
	//王 王 王 一 一 一 二 三 四 五  王是3个，到这里手牌数肯定是模除3余1
	size_t handSize = handpokers.size();
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	int type = 0;
	switch (handSize)
	{
	case 1:
	{
		for (auto& paiValue : AllPaiValue)
		{
			type = getPaiType(paiValue);
			Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type - 1]);
		}
		break;
	}
	case 4:
	{
		const vector<vector<int>> indexValue   //三张组合 打出一张单挑情况
		{
			{0,1,2,3},
			{0,2,1,3},
			{0,3,1,2}
		};
		vector<int> type(4, 0);
		vector<int> value(4, 0);
		
		for (int i = 0; i < handpokers.size(); i++)
		{
			type[i] = getPaiType(handpokers[i]);
			value[i] = getPaiValue(handpokers[i]);
		}

		for (const auto &comb : indexValue)
		{
			map<int, int> tempChuTing1;
			map<int, int> tempChuTing2;
			setChuTingCard(handpokers, tempChuTing1, value, type, comb[0], comb[1], 0);
			setChuTingCard(handpokers, tempChuTing2, value, type, comb[2], comb[3], 0);
			size_t size1 = tempChuTing1.size();
			size_t size2 = tempChuTing2.size();

			if (size1 && size2)      //能解决2对
			{
				for (auto& paiValue : AllPaiValue)
				{
					Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempChuTing1[paiValue] + tempChuTing2[paiValue]);
				}
				break;
			}
		
			if (size1)
			{
				vector<int> temComs1(2, handpokers[comb[2]]);
				vector<int> temComs2(2, handpokers[comb[3]]);
				vector<int> type1(2, getPaiType(handpokers[comb[2]]));
				vector<int> value1(2, getPaiValue(handpokers[comb[2]]));
				vector<int> type2(2, getPaiType(handpokers[comb[3]]));
				vector<int> value2(2, getPaiValue(handpokers[comb[3]]));
				setChuTingCard(temComs1, res_ting_hu, value1, type1, 0, 1, tempHuxi);
				setChuTingCard(temComs2, res_ting_hu, value2, type2, 0, 1, tempHuxi);
			}
			else if (size2)
			{
				vector<int> temComs1(2, handpokers[comb[0]]);
				vector<int> temComs2(2, handpokers[comb[1]]);
				vector<int> type1(2, getPaiType(handpokers[comb[0]]));
				vector<int> value1(2, getPaiValue(handpokers[comb[0]]));
				vector<int> type2(2, getPaiType(handpokers[comb[1]]));
				vector<int> value2(2, getPaiValue(handpokers[comb[1]]));
				setChuTingCard(temComs1, res_ting_hu, value1, type1, 0, 1, tempHuxi);
				setChuTingCard(temComs2, res_ting_hu, value2, type2, 0, 1, tempHuxi);
			}
		}

		break;
	}
	//7张不会到这来
	default:
		cout << "DThreeKindPaiTingResErr: handSize = " << handSize << endl;
		break;
	}
}

void DFourKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	//王 王 王 王 一 一 一 二 三 四  王是4个，到这里手牌数肯定是模除3余0
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	size_t handSize = handpokers.size();
	switch (handSize)
	{
	case 0:
	{
		DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi + paixingHuxi.at(PaiXinHuxi::d_xiao));
		break;
	}
	case 3:
	{
		const vector<vector<int>> indexValue   //三张组合 打出一张单挑情况
		{
			{0,1,2},
			{0,2,1},
			{1,2,0}
		};

		vector<int> type(3, 0);
		vector<int> value(3, 0);

		for (int i = 0; i < handpokers.size(); i++)
		{
			type[i] = getPaiType(handpokers[i]);
			value[i] = getPaiValue(handpokers[i]);
		}

		for (const auto &comb : indexValue)
		{
			map<int, int> tempChuTing;
			setChuTingCard(handpokers, tempChuTing, value, type, comb[0], comb[1], 0);
			if (tempChuTing.size() != 0)
			{
				for (auto& paiValue : AllPaiValue)
				{
					Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempChuTing[paiValue] + tempTypeHuxi[type[comb[2]] - 1]);
				}
			}
			
			Setres_ting_hu(res_ting_hu, handpokers[comb[2]], tempHuxi + tempTypeHuxi[type[comb[0]] - 1] + tempTypeHuxi[type[comb[1]] - 1]);
		}

		break;
	}
	case 6:
	{
		int kindNum = 3;
		vector<int> tempHandPoker(handpokers);
		vector<int> markTempl = getmarkTempl(tempHandPoker);
		if (markTempl.size() >= kindNum)
		{
			tempHandPoker.emplace_back(kindpai);
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi);
		}
		break;
	}
	default:
		cout << "DFourKindPaiTingRes: handSize = " << handSize << endl;
		break;
	}
}

void SOneKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	//到这肯定是 1张王 和 剩一张牌
	int type = getPaiType(handpokers[0]);
	int value = getPaiValue(handpokers[0]);

	if (value > 1)
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] - 1, tempHuxi);
	}

	if (value > 2)
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] - 2, tempHuxi);
	}

	if (value < 10)
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] + 1, tempHuxi);
	}

	if (value < 9)
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] + 2, tempHuxi);
	}

	Setres_ting_hu(res_ting_hu, handpokers[0], tempHuxi + tempTypeHuxi[type - 1]);
	if (type == 1)
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] + 100, tempHuxi);
	}
	else
	{
		Setres_ting_hu(res_ting_hu, handpokers[0] - 100, tempHuxi);
	}

	//看能否听二七十
	if (value == 2)
	{
		Setres_ting_hu(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type - 1]);
		Setres_ting_hu(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type - 1]);
	}
	else if (value == 7)
	{
		Setres_ting_hu(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type - 1]);
		Setres_ting_hu(res_ting_hu, type * 100 + 10, tempHuxi + tempTypeHuxi[type - 1]);
	}
	else if (value == 10)
	{
		Setres_ting_hu(res_ting_hu, type * 100 + 2, tempHuxi + tempTypeHuxi[type - 1]);
		Setres_ting_hu(res_ting_hu, type * 100 + 7, tempHuxi + tempTypeHuxi[type - 1]);
	}
}

void STwoKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	//2张王  可能余 （0，3，6） 6张大于 4 不会进来
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	int handSise = handpokers.size();

	switch (handSise)
	{
	case 0:
	{
		for (auto& paiValue : AllPaiValue)
		{
			int type = getPaiType(paiValue);
			Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type - 1]);
		}
		break;
	}
	case 3:
	{
		const vector<vector<int>> indexValue   //三张组合 打出一张单挑情况
		{
			{0,1,2},
			{0,2,1},
			{1,2,0}
		};

		vector<int> type(3, 0);
		vector<int> value(3, 0);

		for (int i = 0; i < handpokers.size(); i++)
		{
			type[i] = getPaiType(handpokers[i]);
			value[i] = getPaiValue(handpokers[i]);
		}

		for (const auto &comb : indexValue)
		{
			map<int, int> tempChuTing;
			setChuTingCard(handpokers, tempChuTing, value, type, comb[0], comb[1], 0);
			int maxTempHuxi = 0;
			for (const auto& ting_hu : tempChuTing)
			{
				maxTempHuxi = max(maxTempHuxi, ting_hu.second);
			}
			if (tempChuTing.size() != 0)
			{
				vector<int> temp(1, handpokers[comb[2]]);
				SOneKindPaiTingRes(temp, res_ting_hu, tempHuxi);
			}
		}
		break;
	}
	default:
		break;
	}
}

void SThreeKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	//三张王 剩 2 5 
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	int handSise = handpokers.size();

	vector<int> type(handSise, 0);
	vector<int> value(handSise, 0);

	for (int i = 0; i < handpokers.size(); i++)
	{
		type[i] = getPaiType(handpokers[i]);
		value[i] = getPaiValue(handpokers[i]);
	}

	switch (handSise)
	{
	case 2:
	{
		map<int, int> tempChuTing;
		setChuTingCard(handpokers, tempChuTing, value, type, 0, 1, 0);
		int maxTempHuxi = 0;
		for (const auto& tempHuxi : tempChuTing)
		{
			maxTempHuxi = max(tempHuxi.second, maxTempHuxi);
		}
		if (tempChuTing.size() != 0)
		{
			for (auto& paiValue : AllPaiValue)
			{
				int temptype = getPaiType(paiValue);
				Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + maxTempHuxi + tempTypeHuxi[temptype - 1]);
			}
		}
		
		vector<int> tempHand1(1, handpokers[0]);
		vector<int> tempHand2(1, handpokers[1]);

		SOneKindPaiTingRes(tempHand1, res_ting_hu, tempHuxi + tempTypeHuxi[type[0] - 1]);
		SOneKindPaiTingRes(tempHand2, res_ting_hu, tempHuxi + tempTypeHuxi[type[1] - 1]);

		break;
	}
	case 5:
	{
		int kindNum = 2;
		vector<int> tempHandPoker(handpokers);
		vector<int> markTempl = getmarkTempl(tempHandPoker);
		if (markTempl.size() >= kindNum)
		{
			tempHandPoker.emplace_back(kindpai);
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi);
		}
	}
	default:
		break;
	}
}

void SFourKindPaiTingRes(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int & tempHuxi)
{
	//四张王 剩 1 4 7
	vector<int> tempTypeHuxi = { paixingHuxi.at(PaiXinHuxi::x_xiao),paixingHuxi.at(PaiXinHuxi::d_xiao) };
	int handSise = handpokers.size();

	vector<int> type(handSise, 0);
	vector<int> value(handSise, 0);

	for (int i = 0; i < handpokers.size(); i++)
	{
		type[i] = getPaiType(handpokers[i]);
		value[i] = getPaiValue(handpokers[i]);
	}

	vector<int> tempHandPoker(handpokers);
	vector<int> markTempl = getmarkTempl(tempHandPoker);

	switch (handSise)
	{
	case 1:
	{
		for (auto& paiValue : AllPaiValue)
		{
			int type = getPaiType(paiValue);
			Setres_ting_hu(res_ting_hu, paiValue, tempHuxi + tempTypeHuxi[type - 1]);
		}
		break;
	}
	case 4:
	{
		int kindNum = 2;
		tempHandPoker.emplace_back(kindpai);
		tempHandPoker.emplace_back(kindpai);
		if (markTempl.size() >= kindNum)
		{
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi);
		}
		else if (markTempl.size() >= kindNum - 1)
		{
			tempHandPoker.emplace_back(kindpai);
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi);
		}
		break;
	}
	case 7:
	{
		int kindNum = 3;
		tempHandPoker.emplace_back(kindpai);
		if (markTempl.size() >= kindNum)
		{
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum, tempHuxi);
		}
		else if (markTempl.size() >= kindNum - 1)
		{
			tempHandPoker.emplace_back(kindpai);
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 1, tempHuxi);
		}
		else if (markTempl.size() >= kindNum - 2)
		{
			tempHandPoker.emplace_back(kindpai);
			tempHandPoker.emplace_back(kindpai);
			markDnfTingCard(markTempl, tempHandPoker, res_ting_hu, kindNum - 2, tempHuxi);
		}
		break;
	}
	default:
		break;
	}
}

void markDnfTingCard(const vector<int>& markTempl, vector<int> tempHandPoker, map<int, int>& res_ting_hu, const int& kindNum,const int&tempHuxi)
{
	vector<vector<int>> kindCombis = combination3(markTempl, kindNum);
	for (int k = 0; k < kindNum; k++)
	{
		tempHandPoker.emplace_back();
	}
	size_t handSize = tempHandPoker.size() - 1;
	for (int j = 0; j < kindCombis.size(); j++)
	{

		size_t kindSize = kindCombis[j].size();
		for (int Q = 0; Q < kindSize; Q++)
		{
			tempHandPoker[handSize - Q] = kindCombis[j][Q];
		}
		getTingPai(tempHandPoker, res_ting_hu, tempHuxi);
	}
}

void getKindPai_ting_hu(const vector<int>& handpokers, map<int, int>& res_ting_hu, const int& kindNum,const int& tempHuxi)
{
	size_t handSize = handpokers.size() + kindNum;
	if (handSize % 3 == 1)     //单钓
	{
		switch (kindNum)
		{
		case 1:
		{
			DOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 2:
		{
			DTwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 3:
		{
			DThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 4:
		{
			DFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		default:
			break;
		}
	}
	else
	{
		switch (kindNum)
		{
		case 1:
		{
			SOneKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 2:
		{
			STwoKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 3:
		{
			SThreeKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		case 4:
		{
			SFourKindPaiTingRes(handpokers, res_ting_hu, tempHuxi);
			break;
		}
		default:
			break;
		}
	}
}

int getTingPai(vector<int> handPokers, map<int, int>& res_ting_hu,const int& huxi)
{
	sort(handPokers.begin(), handPokers.end());
	int kindNum = getCountAndDelByhand(handPokers, kindpai);
	vector<vector<int>> xiaoQingPai = resolvexiaoQingPai(handPokers);       //分离四张三张的牌
	int xiaoQingHuxi = getxiaoQingHuxi(xiaoQingPai) + huxi;

	//cout << "xiaoQingPai" << endl;
	//for (int i = 0; i < xiaoQingPai.size(); i++)
	//{
	//	printfvector(xiaoQingPai[i]);
	//}

	sort(handPokers.begin(), handPokers.end());
	//cout << "sortHandPoker" << endl;
	//printfvector(handPokers);
	vector<vector<vector<int>>> res;
	if (handPokers.size() < 3)
	{
		res.emplace_back(vector<vector<int>>());
		res[0].emplace_back(handPokers);
	}
	else
	{
		res = getAllCardCombi(handPokers,kindNum);
		/*cout << "getAllCardCombi————————————————————————————————————————————————" << endl;
		for (int i = 0; i < res.size(); i++)
		{
			for (int j = 0; j < res[i].size(); j++)
			{
				cout << "[";
				for (int k = 0; k < res[i][j].size(); k++)
				{
					cout << res[i][j][k] << " ";
				}
				cout << "]";
			}
			cout << endl;
		}
		cout << "getAllCardCombi————————————————————————————————————————————————" << endl;*/
	}
	vector<int> markTempl;
	int tempHufen = 0;
	if (kindNum > 0)
	{
		for (int i = 0; i < res.size(); i++)	
		{
			if (res[i].back().size() < kindNum * 2)                                      
			{
				tempHufen = GetvalidCombiHufen(res[i]) + xiaoQingHuxi;
				sort(res[i].back().begin(), res[i].back().end());
				getKindPai_ting_hu(res[i].back(),res_ting_hu, kindNum, tempHufen);
			}
			else if (res[i].back().size() <= kindNum * 2 + 2)
			{
				markTempl = getmarkTempl(res[i].back());
				if (markTempl.size() < kindNum) continue;
				markDnfTingCard(markTempl, res[i].back(), res_ting_hu, kindNum, xiaoQingHuxi);
			}
		}
	}
	else
	{	
		for (int i = 0; i < res.size(); i++)
		{
			tempHufen = GetvalidCombiHufen(res[i]) + xiaoQingHuxi;
			if (res[i].back().size() == 2)
			{
				getchuTingPairByTwo(res[i].back(), res_ting_hu, tempHufen);
			}
			else if (res[i].back().size() == 4)
			{
				getchuTingPairByFour(res[i].back(), res_ting_hu, tempHufen);
			}
		}
	}

	return 0;
}

void test()
{
	//vector<int> handPokers = getRandziPai(20);             //随机发牌
	//printfvector(handPokers);
	vector<int> handPokers = { 208, 107, 209, 106, 208, 209, 201, 210, 105, 202, 205,
		109, 104, 201, 202, 205, 210, 105, 204, 210 };
	//handPokers.emplace_back(kindpai);
	//handPokers.emplace_back(kindpai);
	//handPokers.emplace_back(kindpai);
	//handPokers.emplace_back(kindpai);
	
	map<int, int> res;
	int huxi = 0;
	auto start = std::chrono::system_clock::now();

	getTingPai(handPokers,res, huxi);

	auto end = std::chrono::system_clock::now();
	std::chrono::duration<double> elapsed_seconds = end - start;
	std::cout << "elapsed time: " << elapsed_seconds.count() << "s\n";
	for (auto it = res.begin(); it != res.end(); it++)
	{
		cout << " ting:" << it->first << " hufen:" << it->second << endl;
	}
}

int main()         //算听啥
{
	srand(time(0));
	while (getchar())
	{
		test();
	}

	getchar();
	return 0;
}