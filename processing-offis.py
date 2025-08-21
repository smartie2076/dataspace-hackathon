import geopandas
import geopandas as gp
import matplotlib.pyplot as plt

data = gp.read_file('data.json')
data = data[data['wind']!=data['wind'].max()]
print(data.columns)
ax = data.plot('wind', legend=True, cmap='viridis')
ax.set_title('Windkraft pro Gemeinde in kW')
ax.set_xlabel("Latitude")
ax.set_ylabel("Longitude")

plt.savefig('./datamap-offis.png', bbox_inches="tight")
plt.close()

# Processing
max_res = data[['key', 'name', 'geometry', 'id']]
max_res['nennleistung_kW_solar_wind']=data['wind']+data['solar']

ax = max_res.plot('nennleistung_kW_solar_wind', legend=True, cmap='viridis')
ax.set_title('Wind und Solar pro Gemeinde in kW')
ax.set_xlabel("Latitude")
ax.set_ylabel("Longitude")
plt.savefig('./datamap-offis-nennleistung-kW.png', bbox_inches="tight")
plt.close()

max_res.to_file('data-office-nennleistung.geojson', driver='GeoJSON')