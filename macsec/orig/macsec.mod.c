#include <linux/build-salt.h>
#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xedeb23cb, "module_layout" },
	{ 0x60a13e90, "rcu_barrier" },
	{ 0xe8b88c27, "genl_unregister_family" },
	{ 0x9d0d6206, "unregister_netdevice_notifier" },
	{ 0x157fb1a9, "rtnl_link_unregister" },
	{ 0xeef80513, "genl_register_family" },
	{ 0xc002f14, "rtnl_link_register" },
	{ 0xd2da1048, "register_netdevice_notifier" },
	{ 0xa870c1ee, "skb_trim" },
	{ 0xab0f52b7, "genlmsg_put" },
	{ 0x36899aab, "gro_cells_receive" },
	{ 0x56d213d7, "__pskb_pull_tail" },
	{ 0xda85695c, "netif_rx" },
	{ 0xf57c5474, "skb_clone" },
	{ 0xdaf485b9, "pv_lock_ops" },
	{ 0xdbf17652, "_raw_spin_lock" },
	{ 0x9b7fe4d4, "__dynamic_pr_debug" },
	{ 0x9583c437, "skb_copy_expand" },
	{ 0x39db5265, "kfree_skb" },
	{ 0x2ea2c95c, "__x86_indirect_thunk_rax" },
	{ 0xbcdfa8a, "skb_to_sgvec" },
	{ 0xf888ca21, "sg_init_table" },
	{ 0xc82a5643, "skb_cow_data" },
	{ 0x31e615e0, "skb_put" },
	{ 0xea83090c, "skb_push" },
	{ 0x2618236d, "consume_skb" },
	{ 0x10739949, "skb_copy" },
	{ 0xce90062e, "refcount_inc_not_zero_checked" },
	{ 0x9fdecc31, "unregister_netdevice_many" },
	{ 0x4c84257f, "dev_set_mtu" },
	{ 0xf5655288, "gro_cells_init" },
	{ 0x9f54ead7, "gro_cells_destroy" },
	{ 0xaf4130d0, "netif_carrier_on" },
	{ 0xde812790, "dev_uc_unsync" },
	{ 0x6e175667, "dev_mc_unsync" },
	{ 0xedbd9b94, "netif_carrier_off" },
	{ 0xc0e91d50, "ether_setup" },
	{ 0x3c3fce39, "__local_bh_enable_ip" },
	{ 0x1601b892, "dev_queue_xmit" },
	{ 0x53569707, "this_cpu_off" },
	{ 0x4629334c, "__preempt_count" },
	{ 0x7a4497db, "kzfree" },
	{ 0xa5e893a0, "dev_set_promiscuity" },
	{ 0x2b98f235, "dev_set_allmulti" },
	{ 0xd2ee4bca, "dev_uc_sync" },
	{ 0x52854865, "dev_mc_sync" },
	{ 0xcf362369, "dev_uc_del" },
	{ 0x8d80a1dc, "dev_uc_add" },
	{ 0x5c8f2430, "netdev_rx_handler_register" },
	{ 0x68f31cbd, "__list_add_valid" },
	{ 0xbd671048, "__alloc_percpu_gfp" },
	{ 0x4b8456af, "netdev_upper_dev_link" },
	{ 0x368cd407, "dev_get_nest_level" },
	{ 0xe2c65ff7, "register_netdevice" },
	{ 0x8a1f9aa3, "eth_type_trans" },
	{ 0x6b36db18, "___pskb_trim" },
	{ 0x6e174dfe, "skb_pull" },
	{ 0xb0e602eb, "memmove" },
	{ 0x31691e2e, "netdev_rx_handler_unregister" },
	{ 0x338bf7dd, "netdev_upper_dev_unlink" },
	{ 0xe1537255, "__list_del_entry_valid" },
	{ 0x8439db8f, "unregister_netdevice_queue" },
	{ 0x17de3d5, "nr_cpu_ids" },
	{ 0xd41f5402, "cpumask_next" },
	{ 0x2548c032, "__cpu_possible_mask" },
	{ 0x5ecfeec6, "__per_cpu_offset" },
	{ 0xb995798d, "nla_put" },
	{ 0x303c02f6, "nla_put_64bit" },
	{ 0x7c32d0f0, "printk" },
	{ 0x49c41a57, "_raw_spin_unlock_bh" },
	{ 0xb3635b01, "_raw_spin_lock_bh" },
	{ 0x949f7342, "__alloc_percpu" },
	{ 0x287665f6, "kmem_cache_alloc_trace" },
	{ 0xc52f874a, "kmalloc_caches" },
	{ 0xffb65735, "crypto_aead_setauthsize" },
	{ 0x825f174, "crypto_aead_setkey" },
	{ 0x8bdf21af, "crypto_alloc_aead" },
	{ 0xd2b09ce5, "__kmalloc" },
	{ 0xefe92c7c, "crypto_destroy_tfm" },
	{ 0x37a0cba, "kfree" },
	{ 0xc9ec4e21, "free_percpu" },
	{ 0x643e0ce5, "call_rcu_sched" },
	{ 0xedc06d37, "refcount_dec_and_test_checked" },
	{ 0x6e720ff2, "rtnl_unlock" },
	{ 0xc7a4fbed, "rtnl_lock" },
	{ 0xdb7305a1, "__stack_chk_fail" },
	{ 0xf1db1704, "nla_memcpy" },
	{ 0x50d664d, "__dev_get_by_index" },
	{ 0x43dae11a, "nla_parse" },
	{ 0xbdfb6dbb, "__fentry__" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

