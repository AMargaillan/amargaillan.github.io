############################################################
# Route Utilization Analysis (Portfolio Version)
# ----------------------------------------------------------
# This script reproduces the analysis logic I built for a
# field service organization to evaluate technician route
# utilization, overtime, and miss rate.
#
# NOTE: This portfolio version uses small, synthetic
# example data created inside the script. No real company
# data or identifiers are included.
############################################################

# --- Step 1: Load Libraries ---
library(tidyverse)
library(janitor)

# ----------------------------------------------------------
# Step 2: Create Synthetic Example Data
# ----------------------------------------------------------
# In the original project, these were loaded from CSV exports
# (completed orders, scheduled orders, hours, miss rate, and
# a branch directory). For the portfolio, we create small,
# in-memory tables with the same structure.

# Branch directory: maps each branch to a market and region
branch_directory <- tribble(
  ~branch_name,       ~market,      ~region,
  "Branch A",         "North",      "Northwest",
  "Branch B",         "North",      "Northeast",
  "Branch C",         "South",      "Southeast"
) %>%
  clean_names()

# Completed services: actual work performed
completed_services <- tribble(
  ~order_id, ~username, ~duration, ~branch,
  1,         "T001",     90,        "Branch A",
  2,         "T001",     45,        "Branch A",
  3,         "T002",     60,        "Branch B",
  4,         "T003",     120,       "Branch C"
)

# Scheduled orders: planned work
scheduled_orders <- tribble(
  ~workdate,  ~username, ~duration, ~branch,
  "2025-01-01","T001",    180,       "Branch A",
  "2025-01-01","T002",    180,       "Branch B",
  "2025-01-01","T003",    180,       "Branch C"
)

# Hours: weekly hours with regular + non-productive hours
hours <- tribble(
  ~tech_code, ~reg_ot_hours, ~np_hours, ~branch_name,
  "T001",      42,            2,         "Branch A",
  "T002",      38,            1,         "Branch B",
  "T003",      50,            3,         "Branch C"
)

# Miss rate: percentage of scheduled work not completed
miss_rate_data <- tribble(
  ~branch_name, ~miss_rate_percent,
  "Branch A",    "10%",
  "Branch B",    "5%",
  "Branch C",    "18%"
)

# ----------------------------------------------------------
# Step 3: Prepare Summaries
# ----------------------------------------------------------
completed_services <- clean_names(completed_services)
scheduled_orders  <- clean_names(scheduled_orders)
hours             <- clean_names(hours)
miss_rate_data    <- clean_names(miss_rate_data)

# Actual hours by technician
actuals_summary <- completed_services %>%
  filter(!is.na(duration), !is.na(username)) %>%
  group_by(tech_id = username) %>%
  summarise(
    total_actual_duration = sum(duration / 60, na.rm = TRUE),
    .groups = "drop"
  )

# Scheduled hours by technician
schedule_summary <- scheduled_orders %>%
  filter(!is.na(workdate), !is.na(duration), !is.na(username)) %>%
  group_by(tech_id = username) %>%
  summarise(
    total_scheduled_duration = sum(duration / 60, na.rm = TRUE),
    .groups = "drop"
  )

# Overtime by technician (hours beyond 40)
overtime_summary <- hours %>%
  mutate(
    reg_ot_hours = replace_na(reg_ot_hours, 0),
    np_hours     = replace_na(np_hours, 0),
    calculated_overtime = pmax(0, (reg_ot_hours + np_hours) - 40)
  ) %>%
  group_by(tech_id = tech_code) %>%
  summarise(
    total_overtime_hours = sum(calculated_overtime, na.rm = TRUE),
    .groups = "drop"
  )

# Miss rate by branch (convert from % to decimal)
miss_rate_summary <- miss_rate_data %>%
  mutate(
    miss_rate_decimal = as.numeric(str_remove(miss_rate_percent, "%")) / 100
  ) %>%
  filter(!is.na(miss_rate_decimal)) %>%
  group_by(branch_name) %>%
  summarise(
    avg_branch_miss_rate = mean(miss_rate_decimal, na.rm = TRUE),
    .groups = "drop"
  )

# ----------------------------------------------------------
# Step 4: Master Tech List (one row per tech + branch)
# ----------------------------------------------------------
master_tech_list <- bind_rows(
  scheduled_orders %>% distinct(tech_id = username, branch_name = branch),
  completed_services %>% distinct(tech_id = username, branch_name = branch),
  hours %>% distinct(tech_id = tech_code, branch_name)
) %>%
  filter(!is.na(tech_id), !is.na(branch_name)) %>%
  distinct(tech_id, branch_name)

# ----------------------------------------------------------
# Step 5: Join All KPIs
# ----------------------------------------------------------
final_summary <- master_tech_list %>%
  inner_join(branch_directory, by = "branch_name") %>%
  left_join(schedule_summary,  by = "tech_id") %>%
  left_join(actuals_summary,   by = "tech_id") %>%
  left_join(overtime_summary,  by = "tech_id") %>%
  left_join(miss_rate_summary, by = "branch_name") %>%
  mutate(
    total_scheduled_duration = replace_na(total_scheduled_duration, 0),
    total_actual_duration    = replace_na(total_actual_duration, 0),
    total_overtime_hours     = replace_na(total_overtime_hours, 0),
    avg_branch_miss_rate     = replace_na(avg_branch_miss_rate, 0)
  ) %>%
  filter(
    total_scheduled_duration > 0 |
    total_actual_duration    > 0 |
    total_overtime_hours     > 0
  )

# ----------------------------------------------------------
# Step 6: Calculate Scores
# ----------------------------------------------------------
normalize <- function(x) {
  if (max(x) == min(x)) return(rep(1, length(x)))
  (x - min(x)) / (max(x) - min(x))
}

scored_techs <- final_summary %>%
  # Example: assume a 130-hour benchmark capacity per route
  mutate(utilization = total_scheduled_duration / 130) %>%
  mutate(
    util_norm      = normalize(utilization),
    miss_rate_norm = 1 - normalize(avg_branch_miss_rate),
    overtime_norm  = 1 - normalize(total_overtime_hours),
    performance_score = (
      0.5 * util_norm +
      0.3 * miss_rate_norm +
      0.2 * overtime_norm
    )
  ) %>%
  select(
    market, region, branch_name, tech_id,
    performance_score, utilization,
    total_scheduled_duration, total_actual_duration,
    total_overtime_hours, avg_branch_miss_rate
  ) %>%
  arrange(desc(performance_score))

scored_techs

# ----------------------------------------------------------
# Step 7: Branch-Level Recommendations
# ----------------------------------------------------------
branch_kpis <- scored_techs %>%
  group_by(market, region, branch_name) %>%
  summarise(
    average_utilization       = mean(utilization),
    average_performance_score = mean(performance_score),
    average_miss_rate         = mean(avg_branch_miss_rate),
    average_overtime          = mean(total_overtime_hours),
    num_techs                 = n(),
    .groups = "drop"
  )

UTILIZATION_LOW_THRESHOLD  <- 0.75
MISS_RATE_HIGH_THRESHOLD   <- 0.15
OVERTIME_HIGH_THRESHOLD    <- 40

branch_recommendations <- branch_kpis %>%
  mutate(
    recommendation = case_when(
      average_utilization < UTILIZATION_LOW_THRESHOLD &
        (average_miss_rate > MISS_RATE_HIGH_THRESHOLD |
         average_overtime > OVERTIME_HIGH_THRESHOLD) ~
        "CRITICAL: Under-scheduled with high miss rate or overtime. Review route structure for consolidation.",
      average_utilization < UTILIZATION_LOW_THRESHOLD ~
        "OPPORTUNITY: Underutilized routes. Consider combining routes to increase efficiency and reduce headcount needs.",
      average_utilization > 0.95 &
        (average_miss_rate > MISS_RATE_HIGH_THRESHOLD |
         average_overtime > OVERTIME_HIGH_THRESHOLD) ~
        "HEADCOUNT NEEDED: Routes at full capacity and showing strain. Evaluate need for additional staffing.",
      average_miss_rate > MISS_RATE_HIGH_THRESHOLD ~
        "EFFICIENCY ISSUE: High miss rate with manageable utilization. Review scheduling practices and route design.",
      average_overtime > OVERTIME_HIGH_THRESHOLD ~
        "CAPACITY ISSUE: Overtime consistently high. Analyze workload and route density.",
      TRUE ~
        "HEALTHY: KPIs within target ranges. Maintain current operational practices."
    )
  ) %>%
  arrange(average_performance_score)

branch_recommendations
