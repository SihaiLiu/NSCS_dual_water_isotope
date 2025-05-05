function deleteTicks
    % Remove tick marks from the top and right borders
    ax=gca; box off
    XLineHdl=plot(ax,ax.XLim([1,2]),ax.YLim([2,2]),'LineWidth',ax.LineWidth,'Color',ax.XColor, 'HandleVisibility','off');
    YLineHdl=plot(ax,ax.XLim([2,2]),ax.YLim([1,2]),'LineWidth',ax.LineWidth,'Color',ax.YColor, 'HandleVisibility','off');
    addlistener(ax,'MarkedClean',@changeLinePos)
    function changeLinePos(~,~)
        set(XLineHdl,'XData',ax.XLim([1,2]),'YData',ax.YLim([2,2]))
        set(YLineHdl,'XData',ax.XLim([2,2]),'YData',ax.YLim([1,2]))
    end
end

