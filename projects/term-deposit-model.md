---
layout: default
title: Term Deposit Subscription Prediction Model
---

# Term Deposit Subscription Prediction Model
**Course:** DAT-520 – Decision Analysis  
**Tools:** Power BI (Decision Tree), Power BI Forecasting, Excel, Statistical Evaluation  
**Techniques:** Decision Trees, Bottom-Up Modeling, Feature Selection, Binning, Forecasting, Error Rate Analysis  

## 🔍 Overview
This project uses a term-deposit marketing dataset to identify which customer conditions most strongly influence whether an individual will subscribe to a term deposit. The model was built and iterated in Power BI using a **bottom-up decision tree approach**, emphasizing interpretability, feature impact, and accuracy.

## 🎯 Objective
To develop a predictive model that helps analysts or marketing teams understand which features most reliably predict subscription behavior and how model tuning affects performance.

## 🛠️ Process
1. **Data Preparation**
   - Imported dataset into Power BI  
   - Verified data types and cleaned inconsistencies  
   - Removed unnecessary fields to reduce noise  

2. **Feature Engineering**
   - Binned *duration* into meaningful ranges (0–300, 301–600, 601–900, 901+)  
   - Explored financial indicators (e.g., **euribor3m**, employment variation, consumer indices)  
   - Grouped or simplified job categories to avoid over-fragmentation  

3. **Model Building**
   - Built a **bottom-up decision tree**  
   - Tuned minimum leaf size  
   - Compared model variations to avoid overfitting  
   - Evaluated using **Rel Error** and **CVal Error**

4. **Forecasting**
   - Used Power BI forecasting visuals  
   - Assessed impact of confidence intervals on prediction ranges  

## 📊 Key Insights
- **Call duration** was the strongest predictor of subscription across all iterations.  
- Economic indicators like **euribor3m** also showed meaningful influence.  
- Higher confidence intervals widened forecast bands, illustrating model uncertainty.  
- Binning improved model stability and interpretability.  

## 🧪 Model Performance
- Relative error: *0.11*  
- Cross-validation error: *0.11*  
- Improved stability after feature grouping and binning  

## 📂 Deliverables
- Decision tree screenshot  
- Forecast visualization  
- Model explanation write-up  

## 🖼️ Screenshots
<img width="1401" height="786" alt="image" src="https://github.com/user-attachments/assets/d0491193-7d33-46df-a117-8d6d9c772ef0" />


