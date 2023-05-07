x=categorical({'Q3','Q6','Q10','Q15','Q30','Q50'});
z=[2.891586318,1.99422657,1.907652812,4.71298388,6.007681496,6.718181667;3.229392123,3.36482536,4.089746011,5.204662107,6.761377397,7.978099976];
y=transpose(z);
figure;
bar(x,y);
hBar = bar(y, 0.8);                                                  


ylabel('Signal Intensity','FontSize',18)
set(gca,'linewidth',2,'FontSize',14)
ylim([0 10]);
set(gca,'XTickLabel',x)