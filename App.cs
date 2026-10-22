using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

public class MainWindow : Window
{
    TextBox input; ListBox list; TextBlock status;
    public MainWindow()
    {
        Title = "WPF Task List"; Width = 420; Height = 360;
        WindowStartupLocation = WindowStartupLocation.CenterScreen;
        var root = new DockPanel { Margin = new Thickness(12) };
        var top = new DockPanel { Margin = new Thickness(0,0,0,8) };
        var add = new Button { Content = "Add", Width = 70, Margin = new Thickness(8,0,0,0), Name = "AddButton" };
        add.Click += (s, e) => AddItem();
        DockPanel.SetDock(add, Dock.Right);
        input = new TextBox { Name = "TaskInput", FontSize = 14 };
        top.Children.Add(add); top.Children.Add(input);
        DockPanel.SetDock(top, Dock.Top);
        status = new TextBlock { Name = "StatusText", Text = "0 tasks", Foreground = Brushes.DimGray, Margin = new Thickness(0,8,0,0) };
        DockPanel.SetDock(status, Dock.Bottom);
        var remove = new Button { Content = "Remove selected", Name = "RemoveButton", Margin = new Thickness(0,8,0,0), HorizontalAlignment = HorizontalAlignment.Right, Padding = new Thickness(10,2,10,2) };
        remove.Click += (s, e) => RemoveItem();
        DockPanel.SetDock(remove, Dock.Bottom);
        list = new ListBox { Name = "TaskList", FontSize = 14 };
        root.Children.Add(top); root.Children.Add(status); root.Children.Add(remove); root.Children.Add(list);
        Content = root;
    }
    void AddItem()
    {
        var t = (input.Text ?? "").Trim();
        if (t.Length == 0) { status.Text = "Enter a task first"; return; }
        foreach (var existing in list.Items)
            if (string.Equals((string)existing, t, StringComparison.OrdinalIgnoreCase)) { status.Text = "Task already exists"; return; }
        list.Items.Add(t); input.Clear();
        UpdateCount();
    }
    void RemoveItem()
    {
        if (list.SelectedItem == null) { status.Text = "Select a task to remove"; return; }
        list.Items.Remove(list.SelectedItem);
        UpdateCount();
    }
    void UpdateCount() { status.Text = list.Items.Count + " task" + (list.Items.Count == 1 ? "" : "s"); }
    [STAThread] public static void Main() { new Application().Run(new MainWindow()); }
}
