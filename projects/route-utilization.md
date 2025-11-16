---
layout: default
title: Route Utilization Analysis (RStudio)
---

# Route Utilization Analysis (RStudio)
**Tools:** RStudio, Tidyverse, dplyr, janitor  
**Techniques:** Utilization modeling, normalized scoring, operational analytics, recommendation engine  

## 🔍 Overview
This project evaluates **route utilization and technician performance** using expected duration, actual duration, overtime hours, and missed service rate.  
The goal is to identify branches that are:

- **Overcapacity** (requiring additional headcount)  
- **Underutilized** (opportunities for consolidation)  
- **Experiencing efficiency or capacity issues**  
- **Healthy** (operating within acceptable KPI ranges)

This portfolio version uses **synthetic example data**, but the analysis, scoring logic, and recommendation engine match the real system I developed for a field service organization.

---

## 🎯 Business Problem
Technician routes vary significantly in workload and efficiency. Some routes operate beyond capacity (high OT, high miss rate), while others carry far fewer jobs than expected.

Leadership needed:

- A consistent and data-driven way to evaluate each branch  
- A scoring model for route performance  
- Recommendations for staffing adjustments  
- A replicable weekly/monthly process for updating KPIs  

---

## 🛠️ Analytical Approach

### **Input Metrics**
- **Expected duration** of scheduled jobs  
- **Actual duration** of completed jobs  
- **Overtime hours** (beyond a 40-hour workweek)  
- **Miss rate** (scheduled jobs not completed)  
- **Branch-to-market mapping**

### **Modeling Steps**
1. Clean and standardize all inputs  
2. Summarize KPIs at the technician level  
3. Compute utilization and normalized scores  
4. Generate a weighted **performance score**  
5. Roll up metrics to the branch level  
6. Apply rule-based logic to assign a **Recommendation** category  

### **Performance Score Formula**
```txt
50%  utilization (normalized)
30%  miss rate (inverted: lower is better)
20%  overtime (inverted: lower is better)
