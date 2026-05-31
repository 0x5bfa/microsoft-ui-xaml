# Framework package PRI

This project is for the framework package only, and `Microsoft.UI.Xaml.pri` is picked up by the framework package.
The resource dictionary below allows a single URI to access `Compact.xaml` from both the framework package and NuGet package.

```xml
<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
    <ResourceDictionary.MergedDictionaries>
        <ResourceDictionary Source="ms-appx:///Microsoft.UI.Xaml/DensityStyles/Compact.xaml"/>
    </ResourceDictionary.MergedDictionaries>
</ResourceDictionary>
```
