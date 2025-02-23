install.packages("ggplot2")
library(ggplot2)
install.packages("haven")
library(haven)
lasso_full <- read_dta("/Users/Mahiru/Documents/Stata/lasso_full.dta")
head(lasso_full)
model <- lm(n_owners ~ ., data = lasso_full)
summary(model)

coefficients <- coef(model)
print(coefficients)
p_values <- summary(model)$coefficients[, 4]
print(p_values)

# all coefficients
regression_results <- as.data.frame(summary(model)$coefficients)
colnames(regression_results) <- c("Estimate", "StdError", "tValue", "PValue")
regression_results$Variable <- rownames(regression_results)
regression_results$BubbleSize <- -log10(regression_results$PValue)
regression_results <- regression_results[regression_results$Variable != "(Intercept)", ]

ggplot(regression_results, aes(x = Estimate, y = reorder(Variable, Estimate), size = BubbleSize, color = PValue)) +
  geom_point(alpha = 0.7) +  # Add bubbles
  scale_color_gradient(low = "blue", high = "red") +  # Color based on p-value
  labs(title = "Regression Coefficients Bubble Chart",
       x = "Regression Coefficient",
       y = "Variable",
       size = "-log10(P-Value)",
       color = "P-Value") +
  theme_minimal()

# only keep values with p<=0.05
regression_results <- as.data.frame(summary(model)$coefficients)
regression_results_sig <- subset(regression_results, p_values <= 0.05)
colnames(regression_results_sig) <- c("Estimate", "StdError", "tValue", "PValue")
regression_results_sig$Variable <- rownames(regression_results_sig)
regression_results_sig$BubbleSize <- -log10(regression_results_sig$PValue)

library(ggplot2)
ggplot(regression_results_sig, aes(x = Estimate, y = reorder(Variable, Estimate), 
                                   size = BubbleSize, color = PValue)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(title = "Significant Regression Coefficients",
       x = "Regression Coefficient",
       y = "Variable",
       size = "-log10(P-Value)",
       color = "P-Value") +
  theme_minimal()