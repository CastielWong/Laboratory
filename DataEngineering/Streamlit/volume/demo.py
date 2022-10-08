#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Example code to demonstrate Streamlit usage."""
from scipy.stats import norm
import numpy as np
import matplotlib.pyplot as plt
import streamlit as st

st.title("Normal distribution")

mu_in = st.slider("Mean", value=5, min_value=-10, max_value=10)
std_in = st.slider("Standard deviation", value=5.0, min_value=0.0, max_value=10.0)
size = st.slider("Number of samples", value=100, max_value=500)

# mu_in = 5
# std_in = 5.0
# size = 100

data = norm.rvs(mu_in, std_in, size=size)

# Fit the normal distribution
mu, std = norm.fit(data)

# Make some plots
x = np.linspace(-40, 40, 100)
y = norm.pdf(x, mu, std)

title = f"Fit results: {mu=:.2f},  {std=:.2f}"

fig, ax = plt.subplots()
ax.hist(data, bins=50, density=True)
ax.plot(x, y, "k", linewidth=2)
ax.set_title(title)

# plt.show()

st.pyplot(fig)
